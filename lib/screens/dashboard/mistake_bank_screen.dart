import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/learning/mistake_model.dart';
import '../../services/flashcard_provider.dart';
import '../../services/ai/ai_provider_manager.dart';
import '../../services/theme_service.dart';

class MistakeBankScreen extends StatefulWidget {
  const MistakeBankScreen({super.key});

  @override
  State<MistakeBankScreen> createState() => _MistakeBankScreenState();
}

class _MistakeBankScreenState extends State<MistakeBankScreen> {
  String _filter = "unresolved"; // "unresolved", "resolved", "all"

  Future<void> _markResolved(String docId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('mistakes')
        .doc(userId)
        .collection('items')
        .doc(docId)
        .update({'reviewStatus': 'resolved'});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mistake marked as resolved! 🎉"),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  Future<void> _addToFlashcards(MistakeModel m) async {
    final flashcardProvider = Provider.of<FlashcardProvider>(context, listen: false);
    await flashcardProvider.addCard(
      question: m.question,
      answer: "Correct Answer: ${m.correctAnswer}\n\nExplanation:\n${m.explanation}",
      topicId: m.topicId,
      tags: [m.topicId, 'mistake-review'],
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added mistake to Smart Flashcards! 🎴"),
          backgroundColor: AppColors.cyan,
        ),
      );
    }
  }

  void _explainAgainDialog(MistakeModel m) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("AI Tutor Explanation", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
        content: FutureBuilder<String>(
          future: AiProviderManager().generateResponse(
            prompt: "Explain this question and why '${m.correctAnswer}' is the correct answer in simple, step-by-step terms:\n\nQuestion: ${m.question}\nCorrect Answer: ${m.correctAnswer}",
            feature: AiFeature.quickExplanation,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
              );
            }
            return SingleChildScrollView(
              child: SelectableText(
                snapshot.data ?? "Explanation unavailable.",
                style: const TextStyle(color: AppColors.primaryText, fontSize: 13.5, height: 1.5),
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text("Got it!", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _tryAgainDialog(MistakeModel m, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Try Again", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.question, style: const TextStyle(color: AppColors.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              const Text("Correct Answer is:", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
              const SizedBox(height: 4),
              Text(m.correctAnswer, style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              onPressed: () {
                _markResolved(docId);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: const Text("Mark Resolved", style: TextStyle(color: AppColors.goldInk, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Mistake Bank", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.primaryText,
      ),
      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _filterChip("Unresolved", "unresolved"),
                const SizedBox(width: 8),
                _filterChip("Resolved", "resolved"),
                const SizedBox(width: 8),
                _filterChip("All", "all"),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mistakes')
                  .doc(user?.uid)
                  .collection('items')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accent));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['reviewStatus'] ?? 'unresolved';
                  if (_filter == 'unresolved') return status != 'resolved';
                  if (_filter == 'resolved') return status == 'resolved';
                  return true;
                }).toList();

                if (docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final m = MistakeModel.fromMap(data);
                    final isResolved = (data['reviewStatus'] ?? '') == 'resolved';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isResolved ? Colors.green.withValues(alpha: 0.4) : Colors.redAccent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(isResolved ? Icons.check_circle_outline : Icons.help_outline, color: isResolved ? Colors.greenAccent : AppColors.accent, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(m.question, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 15, height: 1.4)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text("Your Answer: ${m.studentAnswer}", style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text("Correct Answer: ${m.correctAnswer}", style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 8),
                          const Text("Explanation:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          Text(m.explanation, style: const TextStyle(fontSize: 13, color: AppColors.primaryText, height: 1.4)),
                          const SizedBox(height: 16),

                          // Action Bar
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _tryAgainDialog(m, doc.id),
                                icon: const Icon(Icons.refresh, size: 14, color: AppColors.accent),
                                label: const Text("Try Again", style: TextStyle(color: AppColors.accent, fontSize: 11.5)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.accent)),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _addToFlashcards(m),
                                icon: const Icon(Icons.style_outlined, size: 14, color: AppColors.cyan),
                                label: const Text("+ Flashcard", style: TextStyle(color: AppColors.cyan, fontSize: 11.5)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.cyan)),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _explainAgainDialog(m),
                                icon: const Icon(Icons.psychology_outlined, size: 14, color: AppColors.violet),
                                label: const Text("Explain AI", style: TextStyle(color: AppColors.violet, fontSize: 11.5)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.violet)),
                              ),
                              if (!isResolved)
                                ElevatedButton.icon(
                                  onPressed: () => _markResolved(doc.id),
                                  icon: const Icon(Icons.check, size: 14, color: AppColors.goldInk),
                                  label: const Text("Resolve", style: TextStyle(color: AppColors.goldInk, fontSize: 11.5, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(horizontal: 12)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String key) {
    final isSel = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSel,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(color: isSel ? AppColors.goldInk : AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 12),
      onSelected: (_) => setState(() => _filter = key),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.greenAccent),
            SizedBox(height: 20),
            Text("No mistakes found! Keep up the great work.", style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text("Incorrect quiz questions will automatically appear here for review.", style: TextStyle(color: AppColors.secondaryText, fontSize: 12.5), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
