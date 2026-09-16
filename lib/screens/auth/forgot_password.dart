import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password
  bool _loading = false;
  bool _obscurePassword = true;
  String _generatedOtp = "";
  
  // Timer for Resend OTP
  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;

  final AuthService _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      }
    });
  }

  Future<void> _handleSendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains("@")) {
      _showError("Please enter a valid email address.");
      return;
    }

    setState(() => _loading = true);
    try {
      final otp = await _auth.sendPasswordResetOTP(email);
      _generatedOtp = otp;
      _startResendTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "6-digit OTP code sent to $email",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF0288D1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        setState(() {
          _currentStep = 2;
        });
      }
    } catch (e) {
      _showError("Failed to send OTP: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleVerifyOTP() async {
    final enteredOtp = _otpControllers.map((c) => c.text.trim()).join();
    if (enteredOtp.length < 6) {
      _showError("Please enter the complete 6-digit OTP code.");
      return;
    }

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      final isValid = await _auth.verifyOTP(email, enteredOtp);

      if (isValid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "🔒 OTP Code Verified Successfully!",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        setState(() {
          _currentStep = 3;
        });
      } else {
        _showError("Invalid or expired OTP code. Please try again.");
      }
    } catch (e) {
      _showError("OTP verification error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSetNewPassword() async {
    final p1 = _newPasswordController.text.trim();
    final p2 = _confirmPasswordController.text.trim();

    if (p1.length < 6) {
      _showError("Password must be at least 6 characters long.");
      return;
    }

    if (p1 != p2) {
      _showError("Passwords do not match. Please re-enter.");
      return;
    }

    setState(() => _loading = true);
    try {
      final email = _emailController.text.trim();
      await _auth.updatePasswordWithOTP(email, p1);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "🔒 Password reset successful! You can now sign in.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Error resetting password: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      appBar: AppBar(
        title: const Text("Reset Password", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF1E2126),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: isDesktop ? 550 : double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2126),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step Indicator Bar
                Row(
                  children: [
                    _stepIndicatorItem(1, "1. Email"),
                    _stepIndicatorDivider(),
                    _stepIndicatorItem(2, "2. OTP"),
                    _stepIndicatorDivider(),
                    _stepIndicatorItem(3, "3. Password"),
                  ],
                ),
                const SizedBox(height: 28),

                if (_currentStep == 1) _buildStep1Email(),
                if (_currentStep == 2) _buildStep2OTP(),
                if (_currentStep == 3) _buildStep3NewPassword(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepIndicatorItem(int stepNumber, String label) {
    final isActive = _currentStep == stepNumber;
    final isDone = _currentStep > stepNumber;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF0288D1)
                  : (isDone ? const Color(0xFF2E7D32) : Colors.black26),
              border: Border.all(
                color: isActive ? const Color(0xFF0288D1) : (isDone ? const Color(0xFF4CAF50) : Colors.white24),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    "$stepNumber",
                    style: TextStyle(
                      color: isActive || isDone ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _stepIndicatorDivider() {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white12,
    );
  }

  // STEP 1: Enter Email
  Widget _buildStep1Email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Forgot Your Password?",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Enter your registered email address below. We'll send a 6-digit OTP code to verify your identity.",
          style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),

        const Text("Email Address", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: "name@example.com",
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _handleSendOTP,
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            label: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("SEND 6-DIGIT OTP CODE", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: Verify 6-Digit OTP
  Widget _buildStep2OTP() {
    final email = _emailController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enter 6-Digit OTP Code",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "We sent a security OTP verification code to:\n$email",
          style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),

        // 6 OTP Input Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 44,
              height: 52,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0288D1), width: 2)),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        // Resend Timer Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _canResend ? "Didn't receive code?" : "Resend code in ${_resendCountdown}s",
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            if (_canResend)
              TextButton(
                onPressed: _handleSendOTP,
                child: const Text("Resend OTP", style: TextStyle(color: Color(0xFF0288D1), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _handleVerifyOTP,
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            label: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("VERIFY OTP CODE", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: Set New Password
  Widget _buildStep3NewPassword() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Set New Password",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "OTP verified successfully! Create a new strong password for your account.",
          style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 24),

        const Text("New Password", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Enter New Password (min 6 characters)",
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
          ),
        ),
        const SizedBox(height: 16),

        const Text("Confirm New Password", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: "Re-enter New Password",
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            prefixIcon: const Icon(Icons.lock_clock_outlined, color: Colors.white38),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white12)),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _loading ? null : _handleSetNewPassword,
            icon: _loading
                ? const SizedBox.shrink()
                : const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 20),
            label: _loading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text("SET NEW PASSWORD & SIGN IN", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
