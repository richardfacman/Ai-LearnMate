import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/quiz_provider.dart';
import '../../services/mastery_provider.dart';
import '../../services/user_provider.dart';
import '../../services/achievement_provider.dart';
import '../../services/learning_provider.dart';
import '../../services/theme_service.dart';
import '../../models/learning/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final String? summarizedText;
  const QuizScreen({super.key, this.summarizedText});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizDifficulty _selectedDifficulty = QuizDifficulty.medium;
  int _questionCount = 5;
  String _selectedLanguage = "English";
  bool _isAdaptive = false;

  final _subjectCtrl = TextEditingController();
  final _topicCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final learning = Provider.of<LearningProvider>(context, listen: false);
      learning.fetchSubjects();
      if (learning.subjects.isNotEmpty) {
        _subjectCtrl.text = learning.subjects.first.name;
      } else {
        _subjectCtrl.text = "General Computer Science";
      }
      _topicCtrl.text = "Algorithms & Data Structures";
    });
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("AI Quick Quiz Lab", style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'serif')),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: quizProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 20),
                  Text("Generating personalized quiz...", style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("AI is crafting questions and step-by-step explanations...", style: TextStyle(color: AppColors.secondaryText, fontSize: 12.5)),
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
    final learning = Provider.of<LearningProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quiz Settings", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText, fontFamily: 'serif')),
              const SizedBox(height: 6),
              const Text("Customize your practice session to target specific topics.", style: TextStyle(color: AppColors.secondaryText, fontSize: 13.5)),
              const SizedBox(height: 24),

              // Subject & Topic Selection
              if (learning.subjects.isNotEmpty) ...[
                const Text("Subject", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 14)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: learning.subjects.any((s) => s.name == _subjectCtrl.text) ? _subjectCtrl.text : learning.subjects.first.name,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(filled: true, fillColor: AppColors.card),
                  items: learning.subjects.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _subjectCtrl.text = val);
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                TextField(
                  controller: _subjectCtrl,
                  style: const TextStyle(color: AppColors.primaryText),
                  decoration: const InputDecoration(hintText: "Subject Name (e.g. Physics, History)"),
                ),
                const SizedBox(height: 16),
              ],

              TextField(
                controller: _topicCtrl,
                style: const TextStyle(color: AppColors.primaryText),
                decoration: const InputDecoration(hintText: "Topic Name (e.g. Binary Search, Newton's Laws)"),
              ),
              const SizedBox(height: 24),

              // Difficulty Choice
              const Text("Difficulty", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: QuizDifficulty.values.map((d) {
                  final isSel = _selectedDifficulty == d;
                  return ChoiceChip(
                    label: Text(d.name[0].toUpperCase() + d.name.substring(1)),
                    selected: isSel,
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(color: isSel ? AppColors.goldInk : AppColors.primaryText, fontWeight: FontWeight.bold),
                    onSelected: (val) => setState(() => _selectedDifficulty = d),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Question Count Choice
              const Text("Question Count", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: [5, 10, 15, 20].map((c) {
                  final isSel = _questionCount == c;
                  return ChoiceChip(
                    label: Text("$c Questions"),
                    selected: isSel,
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(color: isSel ? AppColors.goldInk : AppColors.primaryText, fontWeight: FontWeight.bold),
                    onSelected: (val) => setState(() => _questionCount = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Language Choice
              const Text("Language", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: ["English", "Bangla", "Banglish"].map((lang) {
                  final isSel = _selectedLanguage == lang;
                  return ChoiceChip(
                    label: Text(lang),
                    selected: isSel,
                    selectedColor: AppColors.accent,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(color: isSel ? AppColors.goldInk : AppColors.primaryText, fontWeight: FontWeight.bold),
                    onSelected: (val) => setState(() => _selectedLanguage = lang),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Adaptive Toggle
              SwitchListTile(
                title: const Text("Adaptive Difficulty Mode", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                subtitle: const Text("Automatically adjusts question difficulty based on your mastery score.", style: TextStyle(color: AppColors.secondaryText, fontSize: 12)),
                value: _isAdaptive,
                onChanged: (val) => setState(() => _isAdaptive = val),
                activeColor: AppColors.accent,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final sourceText = widget.summarizedText ??
                        "Subject: ${_subjectCtrl.text.trim()}, Topic: ${_topicCtrl.text.trim()}. Create questions testing core principles, definitions, and problem solving in $_selectedLanguage.";
                    provider.startQuiz(
                      text: sourceText,
                      count: _questionCount,
                      difficulty: _selectedDifficulty,
                      adaptive: _isAdaptive,
                      subject: _subjectCtrl.text.trim(),
                      topic: _topicCtrl.text.trim(),
                      language: _selectedLanguage,
                    );
                  },
                  child: const Text("Start Practice Quiz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
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
            backgroundColor: AppColors.card,
            color: AppColors.accent,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Question ${provider.currentIndex + 1} of ${provider.questions.length}",
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: () => provider.skipQuestion(),
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.secondaryText, size: 18),
                label: const Text("Skip", style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            q.question,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryText, height: 1.4),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, index) {
                final opt = q.options[index];
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
                      backgroundColor: AppColors.card,
                      foregroundColor: AppColors.primaryText,
                      minimumSize: const Size(double.infinity, 56),
                      elevation: 0,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(opt, style: const TextStyle(color: AppColors.primaryText, fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(QuizProvider provider) {
    final double accuracy = provider.questions.isNotEmpty ? (provider.score / provider.questions.length) : 0.0;
    final int incorrect = provider.questions.length - provider.score - provider.skipped;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accuracy >= 0.7 ? Colors.green.withValues(alpha: 0.2) : AppColors.accent.withValues(alpha: 0.2),
                ),
                child: Icon(
                  accuracy >= 0.7 ? Icons.emoji_events : Icons.psychology,
                  size: 64,
                  color: accuracy >= 0.7 ? Colors.greenAccent : AppColors.accent,
                ),
              ),
              const SizedBox(height: 20),

              const Text("Quiz Finished!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryText, fontFamily: 'serif')),
              const SizedBox(height: 6),
              Text(
                "Accuracy: ${(accuracy * 100).toStringAsFixed(1)}%",
                style: const TextStyle(fontSize: 18, color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Summary Stats Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _resStat("Score", "${provider.score}/${provider.questions.length}", Colors.greenAccent),
                    _resStat("Incorrect", "$incorrect", Colors.redAccent),
                    _resStat("Skipped", "${provider.skipped}", AppColors.secondaryText),
                    _resStat("Time", "${provider.timeSpentSeconds}s", AppColors.cyan),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Back to Dashboard", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  final sourceText = widget.summarizedText ??
                      "Subject: ${_subjectCtrl.text.trim()}, Topic: ${_topicCtrl.text.trim()}. Retake practice test.";
                  provider.startQuiz(
                    text: sourceText,
                    count: _questionCount,
                    difficulty: _selectedDifficulty,
                    subject: _subjectCtrl.text.trim(),
                    topic: _topicCtrl.text.trim(),
                  );
                },
                child: const Text("Retake Practice Quiz", style: TextStyle(color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resStat(String label, String val, Color col) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: col, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.secondaryText, fontSize: 11)),
      ],
    );
  }
}
