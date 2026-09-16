import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../dashboard/home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  final _auth = AuthService();

  void _showSecurityVerifiedNotice(String provider) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "🔒 $provider Security Verified • Single ID Linked",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _checkAndPromptSetPassword(UserModel user) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data();
      final bool isFirstTime = data?['isFirstTimeSocialLogin'] == true || data?['hasPassword'] == false;

      if (isFirstTime && mounted) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFF1E2126),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (ctx) {
            final pwdController = TextEditingController();
            final confirmController = TextEditingController();
            bool obscure = true;
            bool saving = false;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    top: 28,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B0FF).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF00B0FF), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome, ${user.name}!",
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Set a password for your account",
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Your identity (${user.email}) is verified. Setting a password allows you to log in directly via Email + Password as well as Social Media.",
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: pwdController,
                        obscureText: obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter New Password (min 6 chars)",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white38),
                            onPressed: () => setModalState(() => obscure = !obscure),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirm Password Field
                      TextField(
                        controller: confirmController,
                        obscureText: obscure,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Confirm New Password",
                          hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                          prefixIcon: const Icon(Icons.lock_clock_outlined, color: Colors.white38),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.2),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white12)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final p1 = pwdController.text.trim();
                                  final p2 = confirmController.text.trim();
                                  if (p1.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Password must be at least 6 characters")),
                                    );
                                    return;
                                  }
                                  if (p1 != p2) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Passwords do not match")),
                                    );
                                    return;
                                  }

                                  setModalState(() => saving = true);
                                  try {
                                    await _auth.setUserPassword(p1);
                                    if (context.mounted) Navigator.pop(context);
                                  } catch (_) {
                                    if (context.mounted) Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00B0FF),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: saving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("SAVE PASSWORD & CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Skip for now", style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isDesktop ? 1000 : size.width * 0.95,
            constraints: BoxConstraints(
              minHeight: isDesktop ? 650 : 0,
            ),
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2126),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                children: [
                  // Left Side: Image with Glassmorphism
                  Expanded(
                    flex: isDesktop ? 5 : 0,
                    child: Container(
                      height: isDesktop ? double.infinity : 250,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=800&q=80"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(color: Colors.black.withOpacity(0.2)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Ai Learn Mate",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(width: 30, height: 2, color: Colors.white),
                                if (isDesktop) const Spacer(),
                                const SizedBox(height: 20),
                                const Text(
                                  "You are",
                                  style: TextStyle(color: Colors.white70, fontSize: 18),
                                ),
                                const Text(
                                  "Most welcome here.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                if (isDesktop) const Spacer(),
                                const SizedBox(height: 20),
                                const Text(
                                  "Already have an account?",
                                  style: TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: const Text(
                                    "Sign In",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Right Side: Dark Form
                  Expanded(
                    flex: isDesktop ? 5 : 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 48.0 : 24.0, 
                        vertical: 32
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome to Ai Learn Mate!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Create your account",
                            style: TextStyle(color: Colors.white60, fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          
                          _buildLabel("Your Name"),
                          _buildDarkField(_name, "Steve Jobs", Icons.person_outline),
                          
                          const SizedBox(height: 16),
                          _buildLabel("Your Email"),
                          _buildDarkField(_email, "name@gmail.com", Icons.email_outlined),
                          
                          const SizedBox(height: 16),
                          _buildLabel("Password"),
                          _buildDarkField(
                            _password,
                            "at least 8 characters",
                            Icons.lock_outline,
                            isPassword: true,
                          ),
                          
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (val) => setState(() => _agreeToTerms = val!),
                                  side: const BorderSide(color: Colors.white30),
                                  activeColor: const Color(0xFF00B0FF),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: "I agree to the ",
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                    children: [
                                      TextSpan(
                                        text: "Terms & Conditions",
                                        style: TextStyle(color: Color(0xFF00B0FF), fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B0FF),
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20, width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text(
                                    "Get Started",
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                          
                          const SizedBox(height: 20),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text.rich(
                                TextSpan(
                                  text: "Are you already member? ",
                                  style: TextStyle(color: Colors.white60, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: "Sign In",
                                      style: TextStyle(color: Color(0xFF00B0FF), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _socialButtonWrapper(
                                child: const GoogleBrandLogo(size: 22),
                                onTap: _handleGoogleSignIn,
                              ),
                              const SizedBox(width: 12),
                              _socialButtonWrapper(
                                child: facebookBrandLogo(size: 22),
                                onTap: _handleFacebookSignIn,
                              ),
                              const SizedBox(width: 12),
                              _socialButtonWrapper(
                                child: linkedInBrandLogo(size: 22),
                                onTap: _handleLinkedInSignIn,
                              ),
                              const SizedBox(width: 12),
                              _socialButtonWrapper(
                                child: githubBrandLogo(size: 22),
                                onTap: _handleGithubSignIn,
                              ),
                              const SizedBox(width: 12),
                              _socialButtonWrapper(
                                child: twitterXBrandLogo(size: 22),
                                onTap: _handleTwitterSignIn,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }

  Widget _buildDarkField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white24, size: 20),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _socialButtonWrapper({required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
          color: Colors.black.withOpacity(0.1),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_agreeToTerms) {
      _showError("Please agree to the terms and conditions");
      return;
    }
    if (_name.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.signUp(_name.text, _email.text, _password.text);
      if (mounted) {
        _showSecurityVerifiedNotice("Account");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.googleSignIn();
      if (user != null && mounted) {
        _showSecurityVerifiedNotice("Google");
        await _checkAndPromptSetPassword(user);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.facebookSignIn();
      if (user != null && mounted) {
        _showSecurityVerifiedNotice("Facebook");
        await _checkAndPromptSetPassword(user);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGithubSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.githubSignIn();
      if (user != null && mounted) {
        _showSecurityVerifiedNotice("GitHub");
        await _checkAndPromptSetPassword(user);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLinkedInSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.linkedInSignIn();
      if (user != null && mounted) {
        _showSecurityVerifiedNotice("LinkedIn");
        await _checkAndPromptSetPassword(user);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleTwitterSignIn() async {
    setState(() => _loading = true);
    try {
      final user = await _auth.twitterSignIn();
      if (user != null && mounted) {
        _showSecurityVerifiedNotice("Twitter / X");
        await _checkAndPromptSetPassword(user);
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
