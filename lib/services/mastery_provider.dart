import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/learning/mastery_model.dart';

class MasteryProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, MasteryModel> _masteryData = {}; // topicId -> MasteryModel
  bool _isLoading = false;

  Map<String, MasteryModel> get masteryData => _masteryData;
  bool get isLoading => _isLoading;

  Future<void> fetchMastery() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('mastery').doc(userId).collection('topics').get();
      _masteryData = {
        for (var doc in snapshot.docs) doc.id: MasteryModel.fromMap(doc.data())
      };
    } catch (e) {
      debugPrint("Error fetching mastery: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMastery(String topicId, bool isCorrect) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final currentMastery = _masteryData[topicId] ?? MasteryModel(
      topicId: topicId,
      userId: userId,
      updatedAt: DateTime.now(),
    );

    int newTotal = currentMastery.totalAttempts + 1;
    int newCorrect = isCorrect ? currentMastery.correctAnswers + 1 : currentMastery.correctAnswers;
    
    // Simple mastery calculation: weighted accuracy
    // More advanced logic would include time decay in future phases
    double newScore = newCorrect / newTotal;

    final updatedMastery = MasteryModel(
      topicId: topicId,
      userId: userId,
      score: newScore,
      updatedAt: DateTime.now(),
      correctAnswers: newCorrect,
      totalAttempts: newTotal,
    );

    await _db.collection('mastery').doc(userId).collection('topics').doc(topicId).set(updatedMastery.toMap());
    _masteryData[topicId] = updatedMastery;
    notifyListeners();
  }

  double getTopicMastery(String topicId) {
    return _masteryData[topicId]?.score ?? 0.0;
  }
}
