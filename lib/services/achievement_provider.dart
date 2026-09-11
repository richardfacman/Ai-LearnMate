import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ai_learn_mate/models/gamification/achievement_model.dart';
import 'package:ai_learn_mate/models/gamification/daily_challenge_model.dart';
import 'package:ai_learn_mate/services/user_provider.dart';

class AchievementProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AchievementModel> _achievements = [];
  DailyChallengeModel? _dailyChallenge;
  bool _isLoading = false;

  List<AchievementModel> get achievements => _achievements;
  DailyChallengeModel? get dailyChallenge => _dailyChallenge;
  bool get isLoading => _isLoading;

  Future<void> fetchAchievements() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _db.collection('achievements').doc(uid).collection('user_achievements').get();
      _achievements = snap.docs.map((doc) => AchievementModel.fromMap(doc.data())).toList();
      
      // Initial list of potential achievements if empty
      if (_achievements.isEmpty) {
        _achievements = [
          AchievementModel(id: 'first_quiz', title: 'First Steps', description: 'Complete your first quiz', icon: '🏆', xpReward: 100),
          AchievementModel(id: 'streak_7', title: 'Consistent Learner', description: 'Maintain a 7-day streak', icon: '🔥', xpReward: 500),
          AchievementModel(id: 'master_10', title: 'Expert', description: 'Master 10 topics', icon: '🎓', xpReward: 1000),
        ];
      }
    } catch (e) {
      debugPrint("Error fetching achievements: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyChallenge() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final now = DateTime.now();
      final dateId = "${now.year}-${now.month}-${now.day}";
      final doc = await _db.collection('daily_challenges').doc(uid).collection('history').doc(dateId).get();
      
      if (doc.exists) {
        _dailyChallenge = DailyChallengeModel.fromMap(doc.data()!);
      } else {
        // Generate a new one
        _dailyChallenge = DailyChallengeModel(
          id: dateId,
          title: "Quiz Master",
          description: "Complete 2 quizzes today",
          targetValue: 2,
          xpReward: 50,
          date: now,
        );
        await _db.collection('daily_challenges').doc(uid).collection('history').doc(dateId).set(_dailyChallenge!.toMap());
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching daily challenge: $e");
    }
  }

  Future<void> updateChallengeProgress(int progress, {UserProvider? userProvider}) async {
    if (_dailyChallenge == null || _dailyChallenge!.isCompleted) return;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    int newVal = _dailyChallenge!.currentValue + progress;
    bool completed = newVal >= _dailyChallenge!.targetValue;

    final updated = DailyChallengeModel(
      id: _dailyChallenge!.id,
      title: _dailyChallenge!.title,
      description: _dailyChallenge!.description,
      targetValue: _dailyChallenge!.targetValue,
      currentValue: newVal,
      xpReward: _dailyChallenge!.xpReward,
      isCompleted: completed,
      date: _dailyChallenge!.date,
    );

    await _db.collection('daily_challenges').doc(uid).collection('history').doc(_dailyChallenge!.id).set(updated.toMap());
    
    if (completed && userProvider != null) {
      await userProvider.updateXP(_dailyChallenge!.xpReward);
    }

    _dailyChallenge = updated;
    notifyListeners();
  }
}
