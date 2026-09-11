import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ai_learn_mate/models/learning/exam_model.dart';
import 'package:ai_learn_mate/services/mastery_provider.dart';

class ExamProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ExamModel> _exams = [];
  bool _isLoading = false;

  List<ExamModel> get exams => _exams;
  bool get isLoading => _isLoading;

  Future<void> fetchExams({MasteryProvider? masteryProvider}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('exams').doc(userId).collection('items').get();
      List<ExamModel> fetchedExams = snapshot.docs.map((doc) => ExamModel.fromMap(doc.data())).toList();
      
      // Calculate readiness for each exam if mastery is available
      if (masteryProvider != null) {
        for (int i = 0; i < fetchedExams.length; i++) {
          double totalMastery = 0;
          if (fetchedExams[i].topicIds.isNotEmpty) {
            for (var tid in fetchedExams[i].topicIds) {
              totalMastery += masteryProvider.getTopicMastery(tid);
            }
            double readiness = totalMastery / fetchedExams[i].topicIds.length;
            fetchedExams[i] = ExamModel(
              id: fetchedExams[i].id,
              userId: fetchedExams[i].userId,
              name: fetchedExams[i].name,
              subjectId: fetchedExams[i].subjectId,
              date: fetchedExams[i].date,
              topicIds: fetchedExams[i].topicIds,
              readinessScore: readiness,
            );
          }
        }
      }
      
      _exams = fetchedExams;
    } catch (e) {
      debugPrint("Error fetching exams: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExam(String name, String subjectId, DateTime date, List<String> topicIds) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final exam = ExamModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      subjectId: subjectId,
      date: date,
      topicIds: topicIds,
    );

    await _db.collection('exams').doc(userId).collection('items').add(exam.toMap());
    await fetchExams();
  }
}
