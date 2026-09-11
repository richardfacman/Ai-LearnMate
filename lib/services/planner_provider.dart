import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/learning/study_plan_model.dart';

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
    // In a real app, this would call an AI service to optimize the schedule
    // For now, we generate a basic plan
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    for (int i = 0; i < topicIds.length; i++) {
      final session = StudySessionModel(
        id: "session_${DateTime.now().millisecondsSinceEpoch}_$i",
        topicId: topicIds[i],
        topicName: "Topic $i", // Should fetch actual name
        type: i % 2 == 0 ? SessionType.learn : SessionType.practice,
        durationMinutes: 30,
        scheduledTime: now.add(Duration(days: i)),
      );
      await _db.collection('study_plans').doc(userId).collection('sessions').doc(session.id).set(session.toMap());
    }

    await fetchPlan();
  }
}
