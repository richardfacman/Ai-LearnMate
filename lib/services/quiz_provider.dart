import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ai_learn_mate/models/learning/quiz_model.dart';
import 'package:ai_learn_mate/models/learning/mistake_model.dart';
import 'package:ai_learn_mate/services/ai/quiz_ai_service.dart';
import 'package:ai_learn_mate/services/mastery_provider.dart';
import 'package:ai_learn_mate/services/user_provider.dart';
import 'package:ai_learn_mate/services/achievement_provider.dart';

class QuizProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = false;
  bool _isAdaptive = false;
  
  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  bool get isComplete => _questions.isNotEmpty && _currentIndex >= _questions.length;

  Future<void> startQuiz({
    required String text,
    int count = 5,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    bool adaptive = false,
  }) async {
    _isLoading = true;
    _isAdaptive = adaptive;
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    notifyListeners();

    try {
      _questions = await QuizAIService.generateQuiz(
        text: text,
        count: count,
        difficulty: difficulty,
      );
    } catch (e) {
      debugPrint("Error starting quiz: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(String answer, {MasteryProvider? masteryProvider, UserProvider? userProvider, AchievementProvider? achievementProvider}) async {
    if (_currentIndex >= _questions.length) return;

    final currentQuestion = _questions[_currentIndex];
    final bool isCorrect = currentQuestion.correctAnswer == answer;

    if (isCorrect) {
      _score++;
    } else {
      await _saveMistake(currentQuestion, answer);
    }

    // Update mastery if provider is available
    if (masteryProvider != null && currentQuestion.topicId != null) {
      await masteryProvider.updateMastery(currentQuestion.topicId!, isCorrect);
    }

    _currentIndex++;
    
    if (isComplete) {
      await _saveQuizAttempt();
      // Reward XP for completing quiz: 10 XP per correct answer + 20 bonus
      if (userProvider != null) {
        int xpReward = (_score * 10) + 20;
        await userProvider.updateXP(xpReward);
      }
      
      // Update Daily Challenge progress (e.g., complete 1 quiz)
      if (achievementProvider != null) {
        await achievementProvider.updateChallengeProgress(1, userProvider: userProvider);
      }
    }

    notifyListeners();
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
      topicId: question.topicId ?? 'general',
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
      results: [], // Could fill this with detailed results if needed
      topicPerformance: {}, // Calculate per topic
    );

    await _db.collection('quiz_attempts').doc(userId).collection('history').add(attempt.toMap());
    
    // Update mastery here in Phase 4
  }
}
