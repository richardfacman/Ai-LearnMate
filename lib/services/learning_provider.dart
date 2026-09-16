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

  Future<void> addSubject(String name, {String? icon}) async {
    if (_subjects.any((s) => s.name.toLowerCase() == name.toLowerCase())) {
      return; // Already added
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newSubject = SubjectModel(id: id, name: name, icon: icon, overallMastery: 0.1);
    _subjects.add(newSubject);
    notifyListeners();

    try {
      await _db.collection('subjects').doc(id).set(newSubject.toMap());
    } catch (e) {
      debugPrint("Error adding subject: $e");
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
    if (_subjects.isEmpty) return "Add your first subject to start learning!";
    return "Ready to start your next session?";
  }
}
