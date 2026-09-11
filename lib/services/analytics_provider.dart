import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnalyticsProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _weeklyMinutes = 0;
  int _quizzesTaken = 0;
  double _avgAccuracy = 0;
  int _streakDays = 0;
  List<double> _weeklyStudyData = [0, 0, 0, 0, 0, 0, 0];
  bool _isLoading = false;

  int get weeklyMinutes => _weeklyMinutes;
  int get quizzesTaken => _quizzesTaken;
  double get avgAccuracy => _avgAccuracy;
  int get streakDays => _streakDays;
  List<double> get weeklyStudyData => _weeklyStudyData;
  bool get isLoading => _isLoading;

  Future<void> fetchAnalytics() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      
      // Fetch study sessions
      final sessionSnap = await _db
          .collection('timers')
          .doc(uid)
          .collection('sessions')
          .where('startTime', isGreaterThan: weekAgo.toIso8601String())
          .get();

      int totalSec = 0;
      List<double> dailyData = [0, 0, 0, 0, 0, 0, 0];
      final activeDays = <String>{};

      for (var s in sessionSnap.docs) {
        final duration = s['duration'] as int;
        totalSec += duration;
        
        final startTime = DateTime.parse(s['startTime']).toLocal();
        activeDays.add("${startTime.year}-${startTime.month}-${startTime.day}");
        
        // Map to 0-6 index for week data
        int dayIndex = startTime.weekday - 1; // 0 for Monday
        dailyData[dayIndex] += duration / 60;
      }

      _weeklyMinutes = (totalSec / 60).round();
      _weeklyStudyData = dailyData;
      _streakDays = activeDays.length;

      // Fetch quiz data
      final quizSnap = await _db
          .collection('quiz_attempts')
          .doc(uid)
          .collection('history')
          .get();

      _quizzesTaken = quizSnap.size;
      double totalAccuracy = 0;
      if (_quizzesTaken > 0) {
        for (var q in quizSnap.docs) {
          final data = q.data();
          double score = (data['score'] as int).toDouble();
          int total = data['totalQuestions'] as int;
          if (total > 0) totalAccuracy += (score / total);
        }
        _avgAccuracy = (totalAccuracy / _quizzesTaken) * 100;
      }

    } catch (e) {
      debugPrint("Error fetching analytics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
