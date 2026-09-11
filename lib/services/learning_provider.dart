import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/learning/subject_model.dart';
import '../models/learning/topic_model.dart';

class LearningProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  List<SubjectModel> _subjects = [];
  List<TopicModel> _topics = [];
  bool _isLoading = false;

  List<SubjectModel> get subjects => _subjects;
  List<TopicModel> get topics => _topics;
  bool get isLoading => _isLoading;

  Future<void> fetchSubjects() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('subjects').get();
      _subjects = snapshot.docs.map((doc) => SubjectModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching subjects: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTopics(String subjectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('topics').where('subjectId', isEqualTo: subjectId).get();
      _topics = snapshot.docs.map((doc) => TopicModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint("Error fetching topics: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getRecommendation() {
    if (_subjects.isEmpty) return "Add some subjects to get started!";
    // Placeholder logic for Phase 1
    // In future phases, this will analyze mastery scores
    return "Ready to start your first session?";
  }
}
