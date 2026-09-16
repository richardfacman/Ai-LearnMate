import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_learn_mate/services/quiz_provider.dart';
import 'package:ai_learn_mate/services/mastery_provider.dart';
import 'package:ai_learn_mate/services/user_provider.dart';
import 'package:ai_learn_mate/services/achievement_provider.dart';
import 'package:ai_learn_mate/models/learning/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final String summarizedText;
  const QuizScreen({super.key, required this.summarizedText});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizDifficulty _selectedDifficulty = QuizDifficulty.medium;
  bool _isAdaptive = false;

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("AI Quiz Lab"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: quizProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  SizedBox(height: 20),
                  Text("Generating personalized quiz...", style: TextStyle(color: Colors.black87, fontSize: 16)),
                ],
              ),
            )
          : quizProvider.questions.isEmpty
              ? _buildSetupView(quizProvider)
              : quizProvider.isComplete
                  ? _buildResultView(quizProvider)
                  : _buildQuizView(quizProvider),
    );
  }

  Widget _buildSetupView(QuizProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quiz Settings",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          const Text(
            "Customize your practice session to target specific areas.",
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 30),
          const Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: QuizDifficulty.values.map((d) {
              return ChoiceChip(
                label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                selected: _selectedDifficulty == d,
                onSelected: (val) => setState(() => _selectedDifficulty = d),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SwitchListTile(
            title: const Text("Adaptive Mode", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            subtitle: const Text("Difficulty adjusts based on your performance.", style: TextStyle(color: Colors.black54)),
            value: _isAdaptive,
            onChanged: (val) => setState(() => _isAdaptive = val),
            activeColor: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => provider.startQuiz(
              text: widget.summarizedText,
              difficulty: _selectedDifficulty,
              adaptive: _isAdaptive,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Start Practice", style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView(QuizProvider provider) {
    final q = provider.questions[provider.currentIndex];
    final masteryProvider = Provider.of<MasteryProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final achievementProvider = Provider.of<AchievementProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (provider.currentIndex + 1) / provider.questions.length,
            backgroundColor: Colors.white,
            color: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 30),
          Text(
            "Question ${provider.currentIndex + 1}/${provider.questions.length}",
            style: const TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Text(
            q.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          ...q.options.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => provider.submitAnswer(
                  opt, 
                  masteryProvider: masteryProvider, 
                  userProvider: userProvider,
                  achievementProvider: achievementProvider,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(double.infinity, 60),
                  elevation: 0,
                  side: const BorderSide(color: Colors.black12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(opt, style: const TextStyle(color: Colors.black87, fontSize: 16)),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResultView(QuizProvider provider) {
    final double accuracy = provider.score / provider.questions.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accuracy > 0.7 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              ),
              child: Icon(
                accuracy > 0.7 ? Icons.emoji_events : Icons.psychology,
                size: 80,
                color: accuracy > 0.7 ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 30),
            const Text("Quiz Finished!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),
            Text(
              "You scored ${provider.score} out of ${provider.questions.length}",
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Back to Dashboard", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => provider.startQuiz(
                text: widget.summarizedText,
                difficulty: _selectedDifficulty,
              ),
              child: const Text("Retake Quiz", style: TextStyle(color: Color(0xFF6C63FF), fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
