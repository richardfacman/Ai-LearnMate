import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/learning/quiz_model.dart';
import '../models/learning/mistake_model.dart';
import 'ai/quiz_ai_service.dart';
import 'mastery_provider.dart';
import 'user_provider.dart';
import 'achievement_provider.dart';

class QuizProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  int _skipped = 0;
  DateTime? _startTime;
  int _timeSpentSeconds = 0;
  bool _isLoading = false;
  bool _isAdaptive = false;

  String? _selectedSubject;
  String? _selectedTopic;
  String _language = "English";

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get skipped => _skipped;
  int get timeSpentSeconds => _timeSpentSeconds;
  bool get isLoading => _isLoading;
  bool get isAdaptive => _isAdaptive;
  bool get isComplete => _questions.isNotEmpty && _currentIndex >= _questions.length;

  Future<void> startQuiz({
    required String text,
    int count = 5,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    bool adaptive = false,
    String? subject,
    String? topic,
    String language = "English",
  }) async {
    _isLoading = true;
    _isAdaptive = adaptive;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _skipped = 0;
    _selectedSubject = subject;
    _selectedTopic = topic;
    _language = language;
    _startTime = DateTime.now();
    notifyListeners();

    try {
      _questions = await QuizAIService.generateQuiz(
        text: text,
        count: count,
        difficulty: difficulty,
        topicId: topic ?? subject ?? 'general',
      );
    } catch (e) {
      debugPrint("Error starting quiz: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void skipQuestion() {
    if (_currentIndex >= _questions.length) return;
    _skipped++;
    _currentIndex++;
    if (isComplete) {
      _finalizeQuiz();
    }
    notifyListeners();
  }

  Future<void> submitAnswer(
    String answer, {
    MasteryProvider? masteryProvider,
    UserProvider? userProvider,
    AchievementProvider? achievementProvider,
  }) async {
    if (_currentIndex >= _questions.length) return;

    final currentQuestion = _questions[_currentIndex];
    final bool isCorrect = currentQuestion.correctAnswer.trim().toLowerCase() == answer.trim().toLowerCase();

    if (isCorrect) {
      _score++;
    } else {
      await _saveMistake(currentQuestion, answer);
    }

    // Update topic mastery
    final topicOrSub = currentQuestion.topicId ?? _selectedTopic ?? _selectedSubject;
    if (masteryProvider != null && topicOrSub != null) {
      await masteryProvider.updateMastery(topicOrSub, isCorrect);
    }

    _currentIndex++;

    if (isComplete) {
      await _finalizeQuiz(userProvider: userProvider, achievementProvider: achievementProvider);
    }

    notifyListeners();
  }

  Future<void> _finalizeQuiz({UserProvider? userProvider, AchievementProvider? achievementProvider}) async {
    if (_startTime != null) {
      _timeSpentSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }

    await _saveQuizAttempt();

    // Reward XP
    if (userProvider != null) {
      int xpReward = (_score * 10) + 20;
      await userProvider.updateXP(xpReward);
      await userProvider.updateStreak();
    }

    // Daily challenge progress
    if (achievementProvider != null) {
      await achievementProvider.updateChallengeProgress(1, userProvider: userProvider);
    }
  }

  Future<void> _saveMistake(QuestionModel question, String studentAnswer) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final mistake = MistakeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      question: question.question,
      studentAnswer: studentAnswer,
      correctAnswer: question.correctAnswer,
      explanation: question.explanation,
      topicId: question.topicId ?? _selectedTopic ?? _selectedSubject ?? 'general',
      createdAt: DateTime.now(),
    );

    await _db.collection('mistakes').doc(userId).collection('items').add(mistake.toMap());
  }

  Future<void> _saveQuizAttempt() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final attempt = QuizAttemptModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      timestamp: DateTime.now(),
      score: _score,
      totalQuestions: _questions.length,
      results: [],
      topicPerformance: {
        _selectedTopic ?? _selectedSubject ?? 'General': _score / (_questions.isEmpty ? 1 : _questions.length),
      },
    );

    await _db.collection('quiz_attempts').doc(userId).collection('history').add(attempt.toMap());
  }
}
