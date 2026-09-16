import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color gold = Color(0xFFF0A93E);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PRIVACY POLICY", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 6),
            const Text("Last updated: October 2026", style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 18),
            _policySection(
              "1. Information We Collect",
              "Ai Learn Mate collects your name, email address, profile picture, study activity, quiz performance, flashcard review intervals, mistake history, and study planner tasks to power the personalized recommendation engine and track your mastery."
            ),
            _policySection(
              "2. AI Processing & Privacy",
              "Queries sent to the AI Tutor, Homework Scanner, and Voice Assistant are processed securely through Vercel serverless proxy functions using Groq, Google Gemini, and OpenRouter APIs. Your personal API keys and raw authentication secrets are never exposed in browser JavaScript or client code."
            ),
            _policySection(
              "3. Device Permissions",
              "Camera and Microphone permissions are requested solely when you choose to use the AI Homework Scanner or Voice AI Tutor features. You can enable or revoke these permissions in your system settings at any time."
            ),
            _policySection(
              "4. User Control & Data Deletion",
              "You retain full control over your data. You can edit your profile, clear chat history, reset study data, or permanently delete your account directly inside the Security settings screen."
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _policySection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: paper, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: muted, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
