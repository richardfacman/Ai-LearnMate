import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/huggingface_service.dart';

class QuizScreen extends StatefulWidget {
  final String summarizedText;
  const QuizScreen({super.key, required this.summarizedText});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _loading = false;
  int _current = 0;
  int _score = 0;
  List<Map<String, dynamic>> _quiz = [];

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> _generateQuiz() async {
    setState(() {
      _loading = true;
      _quiz = [];
      _score = 0;
      _current = 0;
    });

    final questions = await HuggingFaceService.generateQuiz(widget.summarizedText);
    setState(() => _quiz = questions);

    await _db.collection('quizzes')
        .doc(_auth.currentUser!.uid)
        .collection('items')
        .add({
      'createdAt': DateTime.now().toIso8601String(),
      'questions': questions,
      'sourceText': widget.summarizedText,
    });

    setState(() => _loading = false);
  }

  void _answer(String option) {
    final correct = _quiz[_current]['answer'];
    if (option == correct) _score++;
    if (_current < _quiz.length - 1) {
      setState(() => _current++);
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Complete!"),
        content: Text("Your Score: $_score / ${_quiz.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            onPressed: () {
              Navigator.pop(context);
              _generateQuiz();
            },
            child: const Text("Try Again"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFE),
      appBar: AppBar(
        title: const Text("AI Quiz Generator"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007BFF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
            : _quiz.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Generate a quiz from your summarized notes!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text("Generate Quiz", style: TextStyle(color: Colors.white)),
            ),
          ],
        )
            : _buildQuizCard(),
      ),
    );
  }

  Widget _buildQuizCard() {
    final q = _quiz[_current];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question ${_current + 1}/${_quiz.length}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C63FF)),
        ),
        const SizedBox(height: 10),
        Text(q['question'] ?? '', style: const TextStyle(fontSize: 18, color: Colors.black87)),
        const SizedBox(height: 20),
        ...List.generate((q['options'] as List).length, (i) {
          final opt = q['options'][i];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ElevatedButton(
              onPressed: () => _answer(opt),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(opt, style: const TextStyle(color: Colors.white)),
            ),
          );
        }),
      ],
    );
  }
}
