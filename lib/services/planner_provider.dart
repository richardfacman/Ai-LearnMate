import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/learning/study_plan_model.dart';
import 'user_provider.dart';

class PlannerProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<StudySessionModel> _sessions = [];
  bool _isLoading = false;

  List<StudySessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> fetchPlan() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('study_plans').doc(userId).collection('sessions')
          .orderBy('scheduledTime')
          .get();
      _sessions = snapshot.docs.map((doc) => StudySessionModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching plan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> generatePlan(String subjectId, List<String> topicIds) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    for (int i = 0; i < topicIds.length; i++) {
      final topicName = topicIds[i];
      final session = StudySessionModel(
        id: "session_${DateTime.now().millisecondsSinceEpoch}_$i",
        topicId: "topic_$i",
        topicName: topicName,
        type: i % 2 == 0 ? SessionType.learn : SessionType.practice,
        durationMinutes: 30,
        scheduledTime: now.add(Duration(days: i)),
      );
      await _db.collection('study_plans').doc(userId).collection('sessions').doc(session.id).set(session.toMap());
    }

    await fetchPlan();
  }

  Future<void> toggleTaskCompletion(String sessionId, bool isCompleted, {UserProvider? userProvider}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index].isCompleted = isCompleted;
        notifyListeners();

        await _db.collection('study_plans').doc(userId).collection('sessions').doc(sessionId).update({
          'isCompleted': isCompleted,
        });

        if (isCompleted && userProvider != null) {
          await userProvider.updateXP(10);
          await userProvider.updateStreak();
        }
      }
    } catch (e) {
      debugPrint("Error toggling task completion: $e");
    }
  }
}
