import 'package:flutter/material.dart';
import 'dart:math';

class FlashcardScreen extends StatefulWidget {
  final List<Map<String, dynamic>> quizData;
  const FlashcardScreen({super.key, required this.quizData});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _index = 0;
  bool _flipped = false;

  void _next() {
    setState(() {
      _index = (_index + 1) % widget.quizData.length;
      _flipped = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Flashcards")),
        body: const Center(child: Text("No data for flashcards")),
      );
    }
    final q = widget.quizData[_index];
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFE),
      appBar: AppBar(
        title: const Text("Flashcards"),
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
      body: Center(
        child: GestureDetector(
          onTap: () => setState(() => _flipped = !_flipped),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotate = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                builder: (context, child) {
                  final tilt = (rotate.value <= pi / 2) ? rotate.value : pi - rotate.value;
                  return Transform(
                    transform: Matrix4.rotationY(tilt),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
                child: child,
              );
            },
            child: _flipped
                ? _buildCard(q['answer'] ?? "No Answer", true)
                : _buildCard(q['question'] ?? "No Question", false),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: _next,
        child: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildCard(String text, bool back) {
    return Container(
      key: ValueKey(back),
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Color(0xFF2C2C2C)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
