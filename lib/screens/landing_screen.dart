import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../widgets/app_logo.dart';
import 'auth/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppLogo(size: 28),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text(
              "Sign In",
              style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHero(context),
            const SizedBox(height: 80),
            _buildFeaturesGrid(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              "✨ Your AI learning companion",
              style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
          Text.rich(
            TextSpan(
              text: "Smarter ",
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: AppColors.primaryText,
              ),
              children: [
                const TextSpan(text: "learning\n", style: TextStyle(color: AppColors.accent)),
                const TextSpan(text: "for a brighter\n"),
                const TextSpan(text: "future", style: TextStyle(color: AppColors.accent)),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            "AI Learn Mate brings the tools you need to learn, practice and revise into one place — and remembers every question you got wrong until you finally get it right.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.secondaryText, height: 1.5),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                child: const Text("Start learning"),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  // Scroll to features or navigate
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryText,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                ),
                child: const Text("Explore features", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {"icon": Icons.history_edu, "title": "Mistake Bank", "desc": "Never make the same mistake twice."},
      {"icon": Icons.smart_toy_outlined, "title": "AI Tutor", "desc": "24/7 personalized academic help."},
      {"icon": Icons.calendar_month_outlined, "title": "Study Planner", "desc": "Smart scheduling for exams."},
      {"icon": Icons.document_scanner_outlined, "title": "Scanner", "desc": "Digitize notes & textbooks instantly."},
      {"icon": Icons.style_outlined, "title": "Flashcards", "desc": "AI generated spaced repetition."},
      {"icon": Icons.quiz_outlined, "title": "Quick Quiz", "desc": "Test your knowledge on any topic."},
      {"icon": Icons.insights, "title": "Analytics", "desc": "Track your study time and progress."},
      {"icon": Icons.mic_none, "title": "Voice Tutor", "desc": "Talk to your tutor hands-free."},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int columns = constraints.maxWidth > 800 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final f = features[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(f['icon'] as IconData, color: AppColors.accent, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      f['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      f['desc'] as String,
                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
