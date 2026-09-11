import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';
import '../../services/flashcard_provider.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FlashcardProvider>(context, listen: false).fetchCards();
    });
  }

  void _handleReview(int quality, FlashcardProvider provider) {
    provider.reviewCard(provider.cards[_currentIndex], quality);
    setState(() {
      _isFlipped = false;
      if (_currentIndex < provider.cards.length - 1) {
        _currentIndex++;
      } else {
        // Deck finished
        _showFinishedDialog();
      }
    });
  }

  void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Session Complete!"),
        content: const Text("You've reviewed all your due cards for today."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Great!"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FlashcardProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("Smart Flashcards"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.cards.isEmpty
              ? _buildEmptyState()
              : _buildFlashcardView(provider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text("No flashcards due for review!"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Action to add card
            },
            child: const Text("Create a Flashcard"),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardView(FlashcardProvider provider) {
    final card = provider.cards[_currentIndex];

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / provider.cards.length,
            backgroundColor: Colors.white,
            color: const Color(0xFF6C63FF),
          ),
        ),
        const SizedBox(height: 10),
        Text("${_currentIndex + 1} / ${provider.cards.length}"),
        const Spacer(),
        GestureDetector(
          onTap: () => setState(() => _isFlipped = !_isFlipped),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
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
              child: _isFlipped
                  ? _buildCard(card.answer, true)
                  : _buildCard(card.question, false),
            ),
          ),
        ),
        const Spacer(),
        if (_isFlipped) _buildConfidenceRow(provider),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCard(String text, bool back) {
    return Container(
      key: ValueKey(back),
      width: 320,
      height: 450,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            back ? "ANSWER" : "QUESTION",
            style: TextStyle(
              color: back ? Colors.green : Colors.blue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceRow(FlashcardProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _confidenceButton("Again", Colors.red, 0, provider),
          _confidenceButton("Hard", Colors.orange, 3, provider),
          _confidenceButton("Good", Colors.blue, 4, provider),
          _confidenceButton("Easy", Colors.green, 5, provider),
        ],
      ),
    );
  }

  Widget _confidenceButton(String label, Color color, int quality, FlashcardProvider provider) {
    return ElevatedButton(
      onPressed: () => _handleReview(quality, provider),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
