import 'package:flutter/material.dart';
import 'package:ai_learn_mate/services/tutor_service.dart';
import 'package:ai_learn_mate/screens/dashboard/quiz_screen.dart';

class NoteTutorScreen extends StatefulWidget {
  final String originalText;
  final String summary;

  const NoteTutorScreen({
    super.key,
    required this.originalText,
    required this.summary,
  });

  @override
  State<NoteTutorScreen> createState() => _NoteTutorScreenState();
}

class _NoteTutorScreenState extends State<NoteTutorScreen> {
  final TextEditingController _questionCtrl = TextEditingController();
  String _aiResponse = "";
  bool _loading = false;
  String _keyPoints = "";
  List<Map<String, String>> _flashcards = [];

  Future<void> _generateKeyPoints() async {
    setState(() => _loading = true);
    final res = await TutorService.generateKeyPoints(widget.originalText);
    setState(() {
      _keyPoints = res;
      _loading = false;
    });
  }

  Future<void> _askQuestion() async {
    final q = _questionCtrl.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _loading = true;
      _aiResponse = "Thinking...";
    });
    
    final res = await TutorService.askAboutNote(widget.originalText, q);
    
    setState(() {
      _aiResponse = res;
      _loading = false;
    });
    _questionCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Note Tutor"),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Text(widget.summary),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generateKeyPoints,
                  icon: const Icon(Icons.list),
                  label: const Text("Key Points"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(summarizedText: widget.originalText),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz),
                  label: const Text("Quiz"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
              ],
            ),
            
            if (_keyPoints.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("Key Points", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Text(_keyPoints),
              ),
            ],
            
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text("Ask about these notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: _questionCtrl,
              decoration: InputDecoration(
                hintText: "What is the main topic?",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF6C63FF)),
                  onPressed: _askQuestion,
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _askQuestion(),
            ),
            
            if (_aiResponse.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Color(0xFF6C63FF)),
                        SizedBox(width: 8),
                        Text("AI Tutor", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_aiResponse),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
