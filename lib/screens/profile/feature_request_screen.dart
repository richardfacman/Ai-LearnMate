import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeatureRequestScreen extends StatefulWidget {
  const FeatureRequestScreen({super.key});

  @override
  State<FeatureRequestScreen> createState() => _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends State<FeatureRequestScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _benefitCtrl = TextEditingController();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _priority = "Medium";
  bool _loading = false;

  // Theme Tokens
  static const Color ink = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF151A24);
  static const Color surfaceHi = Color(0xFF1B2230);
  static const Color gold = Color(0xFFFFB020);
  static const Color paper = Color(0xFFF4EFE6);
  static const Color muted = Color(0xFF8B93A6);
  static const Color hairline = Color(0x1AF4EFE6);

  Future<void> _submitFeature() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty) {
      _showMsg("Please enter a feature title!");
      return;
    }

    if (desc.length < 10) {
      _showMsg("Please describe your idea in detail (minimum 10 characters).");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      await _db.collection('feature_requests').add({
        'userId': user?.uid ?? 'anonymous',
        'userName': user?.displayName ?? 'Student',
        'userEmail': user?.email ?? 'anonymous',
        'title': title,
        'description': desc,
        'benefits': _benefitCtrl.text.trim(),
        'priority': _priority,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _titleCtrl.clear();
        _descCtrl.clear();
        _benefitCtrl.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thanks! Your feature request has been submitted."),
            backgroundColor: gold,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showMsg("Error submitting request: $e");
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
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _benefitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ink,
      appBar: AppBar(
        title: const Text("Suggest a Feature", style: TextStyle(color: paper, fontSize: 16, fontWeight: FontWeight.w600)),
        backgroundColor: surface,
        foregroundColor: paper,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("HELP SHAPE AI LEARN MATE", style: TextStyle(color: gold, fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
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
                  const Text("Feature Title", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _inputContainer(_titleCtrl, "e.g., Offline Flashcard Audio, Study Squads"),
                  const SizedBox(height: 16),
                  const Text("Importance / Priority", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _priority,
                    dropdownColor: surface,
                    style: const TextStyle(color: paper, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: surfaceHi,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: hairline)),
                    ),
                    items: ["High", "Medium", "Low"]
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text("Feature Description", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _inputContainer(_descCtrl, "Describe the new feature and how it should work...", maxLines: 4),
                  const SizedBox(height: 16),
                  const Text("How Would This Help You?", style: TextStyle(color: muted, fontSize: 12)),
                  const SizedBox(height: 8),
                  _inputContainer(_benefitCtrl, "Explain why this feature is valuable for your study routine...", maxLines: 3),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loading ? null : _submitFeature,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: ink,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: ink, strokeWidth: 2))
                        : const Text("Submit Feature Request", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
