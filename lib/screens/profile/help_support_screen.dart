import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  final List<Map<String, String>> _faqs = const [
    {
      "q": "How does the Recommendation Engine work?",
      "a": "Ai Learn Mate continually tracks your topic mastery, recent quiz scores, mistake history, flashcard review intervals, and exam dates to recommend the single most yield-focused activity for you."
    },
    {
      "q": "How does Spaced Repetition work for Flashcards?",
      "a": "When reviewing flashcards, rating cards as 'Again', 'Hard', 'Good', or 'Easy' recalculates the SuperMemo-2 interval so weak cards reappear daily while mastered cards space out over weeks."
    },
    {
      "q": "What AI models power AI Learn Mate?",
      "a": "Ai Learn Mate features multi-provider failover routing across Groq (openai/gpt-oss-120b), Google Gemini (gemini-3.5-flash), OpenRouter, and NVIDIA NIM."
    },
    {
      "q": "How do Quick Actions in AI Tutor work?",
      "a": "Tapping chips like 'I'm Confused', 'Summarize', 'Example', 'Test Me', or 'Deep Dive' sends your active conversation context to the AI tutor without adding fake prompts to your chat thread."
    },
    {
      "q": "Can I use AI Homework Scanner on Web and Mobile?",
      "a": "Yes! You can capture photos directly with your camera or upload images from your gallery to extract problems and receive step-by-step solutions."
    },
    {
      "q": "Is my learning data backed up?",
      "a": "Yes! All your subjects, quizzes, mistakes, study sessions, and planner tasks sync securely with Cloud Firestore under your account."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Help & Support", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("FREQUENTLY ASKED QUESTIONS", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: hairline),
              ),
              child: ExpansionTile(
                iconColor: gold,
                collapsedIconColor: muted,
                title: Text(faq["q"]!, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(faq["a"]!, style: const TextStyle(color: muted, fontSize: 13, height: 1.5)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
