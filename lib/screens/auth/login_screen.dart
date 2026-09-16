import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';
import 'forgot_password.dart';
import '../dashboard/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF121417),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: isDesktop ? 900 : size.width * 0.95,
            height: isDesktop ? 550 : null,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2126),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              children: [
                // Left Side: Sign In
                Expanded(
                  flex: isDesktop ? 5 : 0,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialIconWrapper(
                              child: const GoogleBrandLogo(size: 22),
                              onTap: _handleGoogleSignIn,
                            ),
                            const SizedBox(width: 12),
                            _socialIconWrapper(
                              child: facebookBrandLogo(size: 22),
                              onTap: _handleFacebookSignIn,
                            ),
                            const SizedBox(width: 12),
                            _socialIconWrapper(
                              child: linkedInBrandLogo(size: 22),
                              onTap: _handleLinkedInSignIn,
                            ),
                            const SizedBox(width: 12),
                            _socialIconWrapper(
                              child: githubBrandLogo(size: 22),
                              onTap: _handleGithubSignIn,
                            ),
                            const SizedBox(width: 12),
                            _socialIconWrapper(
                              child: twitterXBrandLogo(size: 22),
                              onTap: _handleTwitterSignIn,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Or sign in using E-Mail Address",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                        const SizedBox(height: 25),
                        _buildDarkTextField(_email, "Email", Icons.email_outlined, false),
                        const SizedBox(height: 15),
                        _buildDarkTextField(_password, "Password", Icons.lock_outline, true),
                        const SizedBox(height: 15),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            ),
                            child: const Text(
                              "Forgot your password?",
                              style: TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0288D1),
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text("SIGN IN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right Side: Create Account
                Expanded(
                  flex: isDesktop ? 4 : 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0288D1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Create,\nAccount!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Register if you still don't have an account ...",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 40),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 2),
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
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
    );
  }

  Widget _socialIconWrapper({required Widget child, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.2),
          border: Border.all(color: Colors.white12),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildDarkTextField(TextEditingController controller, String hint, IconData icon, bool obscure) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white24, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_email.text.isEmpty || _password.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _auth.login(_email.text, _password.text);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.googleSignIn();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      final err = e.toString();
      if (!err.contains("popup-closed") && !err.contains("user-cancelled") && mounted) {
        final cleanMsg = err.replaceAll("Exception:", "").replaceAll("FirebaseAuthException:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-in: $cleanMsg")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.facebookSignIn();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      final err = e.toString();
      if (!err.contains("popup-closed") && !err.contains("user-cancelled") && mounted) {
        final cleanMsg = err.replaceAll("Exception:", "").replaceAll("FirebaseAuthException:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Facebook Sign-in: $cleanMsg")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGithubSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.githubSignIn();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      final err = e.toString();
      if (!err.contains("popup-closed") && !err.contains("user-cancelled") && mounted) {
        final cleanMsg = err.replaceAll("Exception:", "").replaceAll("FirebaseAuthException:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("GitHub Sign-in: $cleanMsg")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLinkedInSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.linkedInSignIn();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      final err = e.toString();
      if (!err.contains("popup-closed") && !err.contains("user-cancelled") && mounted) {
        final cleanMsg = err.replaceAll("Exception:", "").replaceAll("FirebaseAuthException:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("LinkedIn Sign-in: $cleanMsg")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleTwitterSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final user = await _auth.twitterSignIn();
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      final err = e.toString();
      if (!err.contains("popup-closed") && !err.contains("user-cancelled") && mounted) {
        final cleanMsg = err.replaceAll("Exception:", "").replaceAll("FirebaseAuthException:", "").trim();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Twitter / X Sign-in: $cleanMsg")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
