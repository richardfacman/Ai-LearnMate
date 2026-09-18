import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _descCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _expectedCtrl = TextEditingController();
  final _actualCtrl = TextEditingController();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _problemType = "AI Tutor";
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
    "AI Tutor",
    "Quick Quiz",
    "Flashcards",
    "Pomodoro",
    "Planner",
    "Scanner",
    "Voice",
    "Analytics",
    "Login",
    "Profile",
    "Other",
  ];

  Future<void> _submitReport() async {
    final desc = _descCtrl.text.trim();
    if (desc.length < 10) {
      _showMsg("Please describe the problem (minimum 10 characters).");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      await _db.collection('bug_reports').add({
        'userId': user?.uid ?? 'anonymous',
        'userName': user?.displayName ?? 'Student',
        'userEmail': user?.email ?? 'anonymous',
        'type': _problemType,
        'description': desc,
        'steps': _stepsCtrl.text.trim(),
        'expected': _expectedCtrl.text.trim(),
        'actual': _actualCtrl.text.trim(),
        'platform': kIsWeb ? 'Web' : defaultTargetPlatform.name,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _descCtrl.clear();
        _stepsCtrl.clear();
        _expectedCtrl.clear();
        _actualCtrl.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanks! Your problem report has been submitted."),
            backgroundColor: gold,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showMsg("Error submitting report: $e");
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
    _descCtrl.dispose();
    _stepsCtrl.dispose();
    _expectedCtrl.dispose();
    _actualCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Report a Problem", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("REPORT A BUG OR ISSUE", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                  const Text("Problem Area", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _problemType,
                    dropdownColor: surface,
                    style: const TextStyle(color: paper, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: surfaceHi,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: hairline)),
                    ),
                    items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _problemType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Problem Description", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _inputContainer(_descCtrl, "Describe what went wrong in detail...", maxLines: 4),
                  const SizedBox(height: 16),
                  const Text("Steps to Reproduce (Optional)", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _inputContainer(_stepsCtrl, "1. Opened AI Tutor\n2. Tapped Summarize...", maxLines: 3),
                  const SizedBox(height: 16),
                  const Text("Expected Result (Optional)", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _inputContainer(_expectedCtrl, "What did you expect to happen?", maxLines: 2),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: ink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: ink, strokeWidth: 2))
                        : const Text("Submit Bug Report", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputContainer(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: surfaceHi,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: hairline),
      ),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: paper, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: muted, fontSize: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
