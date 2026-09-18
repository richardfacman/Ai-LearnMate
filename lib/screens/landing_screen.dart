import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../widgets/app_logo.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const AppLogo(size: 28),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text(
              "Sign In",
              style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Register", style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Companion Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.psychology_outlined, color: AppColors.cyan, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Your AI learning companion",
                        style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Main Heading
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      letterSpacing: -0.5,
                      color: AppColors.primaryText,
                    ),
                    children: [
                      const TextSpan(text: "Smarter learning\nfor a "),
                      TextSpan(
                        text: "brighter future",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.accent,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [AppColors.accent, Color(0xFFFFDD9A)],
                            ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Subtitle
                const Text(
                  "AI Learn Mate brings the tools you need to learn, practise and revise into one place — and remembers every question you got wrong until you finally get it right.",
                  style: TextStyle(fontSize: 16, color: AppColors.secondaryText, height: 1.6),
                ),
                const SizedBox(height: 36),

                // Bento Grid Features (Matching ai-learn-mate-mockup.html)
                _buildBentoGrid(context),
                const SizedBox(height: 32),

                // Handwritten Quote
                const Text(
                  "Small steps, big dreams.",
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            // Featured Card: Mistake Bank
            Container(
              width: constraints.maxWidth > 800 ? 340 : double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.card],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.bookmark_border_outlined, color: AppColors.accent, size: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("Most used", style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("Mistake Bank", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText)),
                  const SizedBox(height: 4),
                  const Text("Missed questions return until they stick", style: TextStyle(color: AppColors.secondaryText, fontSize: 12.5)),
                ],
              ),
            ),

            // Other Bento Cells
            _bentoCell(Icons.psychology_outlined, "AI Tutor", AppColors.cyan, constraints),
            _bentoCell(Icons.calendar_today_outlined, "Study Planner", AppColors.violet, constraints),
            _bentoCell(Icons.qr_code_scanner_outlined, "Scanner", AppColors.cyan, constraints),
            _bentoCell(Icons.style_outlined, "Flashcards", AppColors.violet, constraints),
            _bentoCell(Icons.bolt_outlined, "Quick Quiz", AppColors.cyan, constraints),
            _bentoCell(Icons.bar_chart_outlined, "Analytics", AppColors.pink, constraints),
            _bentoCell(Icons.mic_none_outlined, "Voice Tutor", AppColors.violet, constraints),
            _bentoCell(Icons.timer_outlined, "Pomodoro", AppColors.pink, constraints),
          ],
        );
      },
    );
  }

  Widget _bentoCell(IconData icon, String title, Color color, BoxConstraints constraints) {
    final cellWidth = constraints.maxWidth > 800
        ? (constraints.maxWidth - 24) / 3
        : (constraints.maxWidth > 500 ? (constraints.maxWidth - 12) / 2 : double.infinity);

    return Container(
      width: cellWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryText)),
        ],
      ),
    );
  }
}
