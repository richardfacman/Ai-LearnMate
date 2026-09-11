import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? get user => _user;
  bool get isLoading => _user == null;

  UserProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _fetchUserData(firebaseUser.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserData(String uid) async {
    _db.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _user = UserModel.fromMap(snapshot.data()!);
        notifyListeners();
      }
    });
  }

  Future<void> updateXP(int xpToAdd) async {
    if (_user == null) return;
    
    int newXP = _user!.xp + xpToAdd;
    int newLevel = _user!.level;
    
    // Simple level up logic: every 1000 XP
    if (newXP >= newLevel * 1000) {
      newLevel++;
    }

    await _db.collection('users').doc(_user!.uid).update({
      'xp': newXP,
      'level': newLevel,
    });
  }

  Future<void> updateStreak() async {
    if (_user == null) return;
    
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    
    if (_user!.lastStudyDate != null) {
      DateTime lastStudy = DateTime(_user!.lastStudyDate!.year, _user!.lastStudyDate!.month, _user!.lastStudyDate!.day);
      int difference = today.difference(lastStudy).inDays;
      
      if (difference == 1) {
        // Continuous streak
        await _db.collection('users').doc(_user!.uid).update({
          'streak': _user!.streak + 1,
          'lastStudyDate': now.toIso8601String(),
        });
      } else if (difference > 1) {
        // Streak broken
        await _db.collection('users').doc(_user!.uid).update({
          'streak': 1,
          'lastStudyDate': now.toIso8601String(),
        });
      }
    } else {
      // First time
      await _db.collection('users').doc(_user!.uid).update({
        'streak': 1,
        'lastStudyDate': now.toIso8601String(),
      });
    }
  }

  Future<void> updateMood(String mood) async {
    if (_user == null) return;
    await _db.collection('users').doc(_user!.uid).update({'currentMood': mood});
  }
}
