import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _feedbackType = "General Feedback";
  int _rating = 5;
  bool _loading = false;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  final List<String> _types = [
    "General Feedback",
    "Bug Report",
    "Feature Request",
    "AI Tutor Problem",
    "Scanner Problem",
    "Voice Problem",
    "Quiz Problem",
    "Flashcard Problem",
    "Performance Problem",
    "Other",
  ];

  Future<void> _submitFeedback() async {
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (subject.isEmpty) {
      _showMsg("Please enter a subject!");
      return;
    }

    if (message.length < 10) {
      _showMsg("Message must be at least 10 characters long!");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      await _db.collection('feedback').add({
        'userId': user?.uid ?? 'anonymous',
        'userName': user?.displayName ?? 'Student',
        'userEmail': user?.email ?? 'anonymous',
        'type': _feedbackType,
        'subject': subject,
        'message': message,
        'rating': _rating,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _subjectCtrl.clear();
        _messageCtrl.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanks! Your feedback has been submitted."),
            backgroundColor: gold,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showMsg("Error submitting feedback: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: surface),
    );
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Send Feedback", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SHARE YOUR FEEDBACK", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Feedback Category", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _feedbackType,
                    dropdownColor: surface,
                    style: const TextStyle(color: paper, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: surfaceHi,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: hairline)),
                    ),
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _feedbackType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Subject", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: surfaceHi,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hairline),
                    ),
                    child: TextField(
                      controller: _subjectCtrl,
                      style: const TextStyle(color: paper, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Brief summary of your feedback",
                        hintStyle: TextStyle(color: muted, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Rating", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (i) {
                      final starIndex = i + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= _rating ? Icons.star : Icons.star_border,
                          color: gold,
                          size: 28,
                        ),
                        onPressed: () => setState(() => _rating = starIndex),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text("Message", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: surfaceHi,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: hairline),
                    ),
                    child: TextField(
                      controller: _messageCtrl,
                      maxLines: 5,
                      style: const TextStyle(color: paper, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Describe your experience or suggestion in detail...",
                        hintStyle: TextStyle(color: muted, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: ink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: ink, strokeWidth: 2))
                        : const Text("Submit Feedback", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
