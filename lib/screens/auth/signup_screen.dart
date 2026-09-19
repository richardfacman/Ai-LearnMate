import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';
import 'social_security_verification_screen.dart';
import '../dashboard/home_screen.dart';

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

  void _navigateToSecurityVerification(UserModel user, String providerName) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SocialSecurityVerificationScreen(
          user: user,
          providerName: providerName,
        ),
      ),
    );
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
        Navigator.of(context).popUntil((route) => route.isFirst);
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
        _navigateToSecurityVerification(user, "Google");
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
        _navigateToSecurityVerification(user, "Facebook");
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
        _navigateToSecurityVerification(user, "GitHub");
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
        _navigateToSecurityVerification(user, "LinkedIn");
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
        _navigateToSecurityVerification(user, "Twitter / X");
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
