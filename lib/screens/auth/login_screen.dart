import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/app_logo.dart';
import 'forgot_password.dart';
import 'social_security_verification_screen.dart';
import '../dashboard/home_screen.dart';

enum UserRole { student, teacher, parent }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Sign In Controllers
  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();
  bool _rememberMe = true;
  bool _loginLoading = false;

  // Register Controllers
  final _regName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();
  final _regConfirmPassword = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _regLoading = false;

  bool _isDarkMode = true;
  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

  final _auth = AuthService();

  // Color Tokens - Moved to AppColors, using those directly
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentViolet = Color(0xFFB388FF);
  static const Color accentPink = Color(0xFFFF80AB);

  @override
  void dispose() {
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _regConfirmPassword.dispose();
    super.dispose();
  }

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

  Future<void> _handleLogin() async {
    final email = _loginEmail.text.trim();
    final pwd = _loginPassword.text.trim();
    if (email.isEmpty || pwd.isEmpty) {
      _showError("Please enter your email and password.");
      return;
    }

    setState(() => _loginLoading = true);
    try {
      await _auth.login(email, pwd);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError("Login failed: ${e.toString().replaceAll('Exception:', '').trim()}");
      }
    } finally {
      if (mounted) setState(() => _loginLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _regName.text.trim();
    final email = _regEmail.text.trim();
    final p1 = _regPassword.text.trim();
    final p2 = _regConfirmPassword.text.trim();

    if (name.isEmpty || email.isEmpty || p1.isEmpty || p2.isEmpty) {
      _showError("Please fill in all registration fields.");
      return;
    }

    if (p1.length < 8) {
      _showError("Password must be at least 8 characters long.");
      return;
    }

    if (p1 != p2) {
      _showError("Passwords do not match.");
      return;
    }

    setState(() => _regLoading = true);
    try {
      await _auth.signUp(name, email, p1);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _regLoading = false);
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
    final isDesktop = size.width > 1100;
    final isTablet = size.width > 750 && size.width <= 1100;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glowing Color Blobs & Star-dots
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6C7BFF).withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            top: 150,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.08),
              ),
            ),
          ),

          // Main Scrollable Body
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // TOP HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wordmark Logo & Tagline
                      Row(
                        children: [
                          _buildBookLogoMark(size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text("AI Learn ", style: TextStyle(color: AppColors.primaryText, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                                  Text("Mate", style: TextStyle(color: AppColors.accent, fontSize: 22, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                                ],
                              ),
                              const Text(
                                "Learn  ·  Practice  ·  Grow",
                                style: TextStyle(color: accentCyan, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Theme Toggle Pill Button
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.wb_sunny_outlined, color: AppColors.secondaryText, size: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.nightlight_round, color: AppColors.background, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // THREE COLUMN RESPONSIVE LAYOUT
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildLeftHeroColumn()),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _buildSignInCard()),
                        const SizedBox(width: 24),
                        Expanded(flex: 3, child: _buildSignUpCard()),
                      ],
                    )
                  else if (isTablet)
                    Column(
                      children: [
                        _buildLeftHeroColumn(),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildSignInCard()),
                            const SizedBox(width: 20),
                            Expanded(child: _buildSignUpCard()),
                          ],
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildLeftHeroColumn(),
                        const SizedBox(height: 28),
                        _buildSignInCard(),
                        const SizedBox(height: 28),
                        _buildSignUpCard(),
                      ],
                    ),

                  const SizedBox(height: 48),

                  // BOTTOM FOOTER: Trust Badges & Script Accent
                  _buildFooterTrustRow(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LEFT COLUMN: Hero & Bento Feature Grid
  Widget _buildLeftHeroColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.code_rounded, color: accentCyan, size: 14),
              SizedBox(width: 8),
              Text(
                "Your AI learning companion",
                style: TextStyle(color: AppColors.primaryText, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Serif Headline
        Text.rich(
          TextSpan(
            text: "Smarter learning\nfor a ",
            style: const TextStyle(color: AppColors.primaryText, fontSize: 38, fontWeight: FontWeight.bold, height: 1.15, fontFamily: 'serif'),
            children: [
              TextSpan(
                text: "brighter\nfuture",
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppColors.accent, AppColors.accent],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  fontSize: 38,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Paragraph
        const Text(
          "AI Learn Mate brings the tools you need to learn, practise and revise into one place — and remembers every question you got wrong until you finally get it right.",
          style: TextStyle(color: AppColors.secondaryText, fontSize: 13.5, height: 1.5),
        ),
        const SizedBox(height: 28),

        // Bento Feature Grid
        Column(
          children: [
            Row(
              children: [
                // Featured Tile: Mistake Bank (Gold Tinted)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withOpacity(0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: AppColors.accent.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accent, size: 22),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text("Most used", style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Mistake Bank", style: TextStyle(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text("Missed questions return until they stick", style: TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // AI Tutor & Study Planner
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _bentoTile(Icons.psychology_outlined, "AI Tutor", accentCyan),
                      const SizedBox(height: 10),
                      _bentoTile(Icons.check_box_outlined, "Study Planner", accentViolet),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Scanner & Flashcards
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _bentoTile(Icons.crop_free_rounded, "Scanner", accentCyan),
                      const SizedBox(height: 10),
                      _bentoTile(Icons.style_outlined, "Flashcards", accentViolet),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(child: _bentoTile(Icons.event_available_outlined, "Quick Quiz", accentCyan)),
                const SizedBox(width: 10),
                Expanded(child: _bentoTile(Icons.bar_chart_rounded, "Analytics", accentPink)),
                const SizedBox(width: 10),
                Expanded(child: _bentoTile(Icons.mic_none_rounded, "Voice Tutor", accentViolet)),
                const SizedBox(width: 10),
                Expanded(child: _bentoTile(Icons.timer_outlined, "Pomodoro", accentPink)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Script Accent Line
        const Text(
          "Small steps, big dreams.",
          style: TextStyle(color: AppColors.accent, fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontFamily: 'serif'),
        ),
      ],
    );
  }

  Widget _bentoTile(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.primaryText, fontSize: 12, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // MIDDLE COLUMN: Sign In Glass Card
  Widget _buildSignInCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBookLogoMark(size: 28),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("AI Learn ", style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              Text("Mate", style: TextStyle(color: AppColors.accent, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            ],
          ),
          const SizedBox(height: 16),

          const Text("Welcome back", style: TextStyle(color: AppColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 4),
          const Text("12 questions are due for review today.", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          const SizedBox(height: 24),

          // Email Field
          _buildDarkField(_loginEmail, "Email or username", Icons.email_outlined, false),
          const SizedBox(height: 12),

          // Password Field
          _buildDarkField(
            _loginPassword,
            "Password",
            Icons.lock_outline,
            true,
            obscure: _obscureLoginPassword,
            onToggleObscure: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
          ),
          const SizedBox(height: 12),

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val!),
                      activeColor: AppColors.accent,
                      checkColor: AppColors.background,
                      side: const BorderSide(color: AppColors.secondaryText),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Remember me", style: TextStyle(color: AppColors.primaryText, fontSize: 12)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                child: const Text("Forgot password?", style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gold Gradient Sign In Button
          _buildGoldButton("Sign in", _loginLoading, _handleLogin),
          const SizedBox(height: 16),

          const Text("or", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          const SizedBox(height: 16),

          // Social Buttons Row
          _buildSocialButtonsRow(),
          const SizedBox(height: 20),

          // Trust Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.shield_outlined, color: accentCyan, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text("Secure and private — Your notes and answers stay yours", style: TextStyle(color: AppColors.secondaryText, fontSize: 11)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RIGHT COLUMN: Create Account Glass Card
  Widget _buildSignUpCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBookLogoMark(size: 28),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("AI Learn ", style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'serif')),
              Text("Mate", style: TextStyle(color: AppColors.accent, fontSize: 16, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontFamily: 'serif')),
            ],
          ),
          const SizedBox(height: 16),

          const Text("Create your account", style: TextStyle(color: AppColors.primaryText, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif')),
          const SizedBox(height: 4),
          const Text("Under a minute. No card, no trial countdown.", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          const SizedBox(height: 24),

          _buildDarkField(_regName, "Full name", Icons.person_outline, false),
          const SizedBox(height: 12),
          _buildDarkField(_regEmail, "Email address", Icons.email_outlined, false),
          const SizedBox(height: 12),
          _buildDarkField(
            _regPassword,
            "Password, at least 8 characters",
            Icons.lock_outline,
            true,
            obscure: _obscureRegPassword,
            onToggleObscure: () => setState(() => _obscureRegPassword = !_obscureRegPassword),
          ),
          const SizedBox(height: 12),
          _buildDarkField(
            _regConfirmPassword,
            "Confirm password",
            Icons.lock_clock_outlined,
            true,
            obscure: _obscureRegConfirmPassword,
            onToggleObscure: () => setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword),
          ),
          const SizedBox(height: 16),

          // Three-Way Role Selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Select your role", style: TextStyle(color: AppColors.primaryText, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _roleOption(UserRole.student, "Student", "Learn & grow", Icons.school_outlined)),
              const SizedBox(width: 8),
              Expanded(child: _roleOption(UserRole.teacher, "Teacher", "Teach & inspire", Icons.laptop_chromebook_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _roleOption(UserRole.parent, "Parent", "Support & guide", Icons.favorite_border_rounded)),
            ],
          ),
          const SizedBox(height: 20),

          _buildGoldButton("Create account", _regLoading, _handleRegister),
          const SizedBox(height: 16),

          const Text("or", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
          const SizedBox(height: 16),

          _buildSocialButtonsRow(),
        ],
      ),
    );
  }

  Widget _roleOption(UserRole role, String title, String sub, IconData icon) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accent : AppColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.accent : AppColors.secondaryText, size: 18),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: isSelected ? AppColors.accent : AppColors.primaryText, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(sub, style: TextStyle(color: isSelected ? AppColors.accent.withOpacity(0.8) : AppColors.secondaryText, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldButton(String text, bool isLoading, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.accent, AppColors.accent]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.background, strokeWidth: 2))
                : Text(text, style: const TextStyle(color: AppColors.background, fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButtonsRow() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.background,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                GoogleBrandLogo(size: 18),
                SizedBox(width: 10),
                Text("Continue with Google", style: TextStyle(color: AppColors.primaryText, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.background,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.apple_rounded, color: AppColors.primaryText, size: 20),
                SizedBox(width: 10),
                Text("Continue with Apple", style: TextStyle(color: AppColors.primaryText, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _socialIconTile(child: facebookBrandLogo(size: 18), onTap: _handleFacebookSignIn, tooltip: "Facebook"),
            const SizedBox(width: 8),
            _socialIconTile(child: linkedInBrandLogo(size: 18), onTap: _handleLinkedInSignIn, tooltip: "LinkedIn"),
            const SizedBox(width: 8),
            _socialIconTile(child: githubBrandLogo(size: 18), onTap: _handleGithubSignIn, tooltip: "GitHub"),
            const SizedBox(width: 8),
            _socialIconTile(child: twitterXBrandLogo(size: 18), onTap: _handleTwitterSignIn, tooltip: "Twitter / X"),
          ],
        ),
      ],
    );
  }

  Widget _socialIconTile({required Widget child, required VoidCallback onTap, required String tooltip}) {
    return Tooltip(
      message: "Continue with $tooltip",
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _buildDarkField(
    TextEditingController controller,
    String hint,
    IconData icon,
    bool isPassword, {
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && obscure,
        style: const TextStyle(color: AppColors.primaryText, fontSize: 13.5),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.secondaryText, size: 18),
          suffixIcon: isPassword && onToggleObscure != null
              ? IconButton(
                  icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.secondaryText, size: 18),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBookLogoMark({double size = 28}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.menu_book_rounded, color: AppColors.accent, size: size * 0.6),
    );
  }

  Widget _buildFooterTrustRow() {
    return Column(
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: const [
            _TrustBadge(icon: Icons.school_outlined, title: "Personalised", subtitle: "learning"),
            _TrustBadge(icon: Icons.shield_outlined, title: "Safe and secure", subtitle: "your data"),
            _TrustBadge(icon: Icons.bolt_rounded, title: "Powered by", subtitle: "advanced AI"),
            _TrustBadge(icon: Icons.favorite_border_rounded, title: "Built for", subtitle: "better you"),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Let's learn together",
              style: TextStyle(color: AppColors.primaryText, fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600, fontFamily: 'serif'),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded, color: AppColors.background, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_loginLoading || _regLoading) return;
    try {
      final user = await _auth.googleSignIn();
      if (user != null && mounted) {
        _navigateToSecurityVerification(user, "Google");
      }
    } catch (e) {
      _showError("Google Sign-in failed");
    }
  }

  Future<void> _handleFacebookSignIn() async {
    if (_loginLoading || _regLoading) return;
    try {
      final user = await _auth.facebookSignIn();
      if (user != null && mounted) {
        _navigateToSecurityVerification(user, "Facebook");
      }
    } catch (e) {
      _showError("Facebook Sign-in failed");
    }
  }

  Future<void> _handleGithubSignIn() async {
    if (_loginLoading || _regLoading) return;
    try {
      final user = await _auth.githubSignIn();
      if (user != null && mounted) {
        _navigateToSecurityVerification(user, "GitHub");
      }
    } catch (e) {
      _showError("GitHub Sign-in failed");
    }
  }

  Future<void> _handleLinkedInSignIn() async {
    if (_loginLoading || _regLoading) return;
    try {
      final user = await _auth.linkedInSignIn();
      if (user != null && mounted) {
        _navigateToSecurityVerification(user, "LinkedIn");
      }
    } catch (e) {
      _showError("LinkedIn Sign-in failed");
    }
  }

  Future<void> _handleTwitterSignIn() async {
    if (_loginLoading || _regLoading) return;
    try {
      final user = await _auth.twitterSignIn();
      if (user != null && mounted) {
        _navigateToSecurityVerification(user, "Twitter / X");
      }
    } catch (e) {
      _showError("Twitter / X Sign-in failed");
    }
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustBadge({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF00E5FF), size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFFF4EFE6), fontSize: 11.5, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Color(0xFF8B93A6), fontSize: 10.5)),
          ],
        ),
      ],
    );
  }
}

// Brand Logo Widgets
class GoogleBrandLogo extends StatelessWidget {
  final double size;
  const GoogleBrandLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleGLogoPainter(),
      ),
    );
  }
}

class _GoogleGLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final pRed = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.butt;
    final pYellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.butt;
    final pGreen = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.butt;
    final pBlue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, -2.2, 1.4, false, pRed);
    canvas.drawArc(rect, -0.8, 0.9, false, pYellow);
    canvas.drawArc(rect, 0.1, 1.4, false, pGreen);
    canvas.drawArc(rect, -0.2, 0.5, false, pBlue);

    final barPaint = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(center.dx - w * 0.05, center.dy - strokeWidth / 2, radius + w * 0.05, strokeWidth), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget facebookBrandLogo({double size = 24}) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Color(0xFF1877F2),
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      "f",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: size * 0.75,
        fontFamily: 'sans-serif',
        height: 1.0,
      ),
    ),
  );
}

Widget linkedInBrandLogo({double size = 24}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFF0077B5),
      borderRadius: BorderRadius.circular(size * 0.22),
    ),
    alignment: Alignment.center,
    child: Text(
      "in",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: size * 0.6,
        fontFamily: 'sans-serif',
        height: 1.0,
      ),
    ),
  );
}

Widget githubBrandLogo({double size = 24}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFF24292E),
      borderRadius: BorderRadius.circular(size * 0.22),
    ),
    alignment: Alignment.center,
    child: CustomPaint(
      size: Size(size * 0.65, size * 0.65),
      painter: _GithubOctocatPainter(),
    ),
  );
}

Widget twitterXBrandLogo({double size = 24}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFF14171A),
      borderRadius: BorderRadius.circular(size * 0.22),
      border: Border.all(color: const Color(0xFF1DA1F2), width: 1.0),
    ),
    alignment: Alignment.center,
    child: Text(
      "𝕏",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w900,
        fontSize: size * 0.6,
        height: 1.0,
      ),
    ),
  );
}

class _GithubOctocatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final paint = Paint()..color = Colors.white..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.22, 0, 0, h * 0.22, 0, h * 0.5);
    path.cubicTo(0, h * 0.72, w * 0.18, h * 0.9, w * 0.42, h * 0.96);
    path.cubicTo(w * 0.45, h * 0.97, w * 0.46, h * 0.95, w * 0.46, h * 0.93);
    path.lineTo(w * 0.46, h * 0.83);
    path.cubicTo(w * 0.32, h * 0.86, w * 0.29, h * 0.77, w * 0.29, h * 0.77);
    path.cubicTo(w * 0.27, h * 0.71, w * 0.23, h * 0.69, w * 0.23, h * 0.69);
    path.cubicTo(w * 0.18, h * 0.66, w * 0.23, h * 0.66, w * 0.23, h * 0.66);
    path.cubicTo(w * 0.28, h * 0.67, w * 0.31, h * 0.71, w * 0.31, h * 0.71);
    path.cubicTo(w * 0.36, h * 0.8, w * 0.45, h * 0.77, w * 0.48, h * 0.75);
    path.cubicTo(w * 0.49, h * 0.71, w * 0.51, h * 0.67, w * 0.53, h * 0.65);
    path.cubicTo(w * 0.42, h * 0.64, w * 0.3, h * 0.59, w * 0.3, h * 0.39);
    path.cubicTo(w * 0.3, h * 0.33, w * 0.32, h * 0.28, w * 0.36, h * 0.24);
    path.cubicTo(w * 0.35, h * 0.22, w * 0.33, h * 0.16, w * 0.37, h * 0.08);
    path.cubicTo(w * 0.37, h * 0.08, w * 0.42, h * 0.06, w * 0.53, h * 0.14);
    path.cubicTo(w * 0.58, h * 0.12, w * 0.63, h * 0.11, w * 0.68, h * 0.11);
    path.cubicTo(w * 0.73, h * 0.11, w * 0.78, h * 0.12, w * 0.83, h * 0.14);
    path.cubicTo(w * 0.94, h * 0.06, w * 0.99, h * 0.08, w * 0.99, h * 0.08);
    path.cubicTo(w * 1.03, h * 0.16, w * 1.01, h * 0.22, w * 1.0, h * 0.24);
    path.cubicTo(w * 1.04, h * 0.28, w * 1.06, h * 0.33, w * 1.06, h * 0.39);
    path.cubicTo(w * 1.06, h * 0.59, w * 0.94, h * 0.64, w * 0.83, h * 0.65);
    path.cubicTo(w * 0.85, h * 0.67, w * 0.87, h * 0.72, w * 0.87, h * 0.79);
    path.lineTo(w * 0.87, h * 0.93);
    path.cubicTo(w * 0.87, h * 0.95, w * 0.88, h * 0.97, w * 0.92, h * 0.96);
    path.cubicTo(w * 1.15, h * 0.9, w * 1.33, h * 0.72, w * 1.33, h * 0.5);
    path.cubicTo(w * 1.33, h * 0.22, w * 1.11, 0, w * 0.83, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
