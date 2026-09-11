import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/learning/flashcard_model.dart';

class FlashcardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<FlashcardModel> _cards = [];
  bool _isLoading = false;

  List<FlashcardModel> get cards => _cards;
  bool get isLoading => _isLoading;

  Future<void> fetchCards() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('flashcards').doc(userId).collection('items').get();
      _cards = snapshot.docs.map((doc) => FlashcardModel.fromMap(doc.data())).toList();
      
      // Sort by review date
      _cards.sort((a, b) => a.nextReview.compareTo(b.nextReview));
    } catch (e) {
      debugPrint("Error fetching cards: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard(String question, String answer, {String? topicId}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final card = FlashcardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      question: question,
      answer: answer,
      topicId: topicId,
      createdAt: DateTime.now(),
      nextReview: DateTime.now(),
    );

    await _db.collection('flashcards').doc(userId).collection('items').add(card.toMap());
    await fetchCards();
  }

  Future<void> reviewCard(FlashcardModel card, int quality) async {
    // quality: 0 (forgot) to 5 (perfect recall)
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Simplified SM-2 logic
    double newEaseFactor = card.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEaseFactor < 1.3) newEaseFactor = 1.3;

    int newInterval;
    if (quality < 3) {
      newInterval = 0; // Review again today
    } else {
      if (card.intervalDays == 0) newInterval = 1;
      else if (card.intervalDays == 1) newInterval = 6;
      else newInterval = (card.intervalDays * newEaseFactor).round();
    }

    final updatedCard = FlashcardModel(
      id: card.id,
      userId: userId,
      question: card.question,
      answer: card.answer,
      topicId: card.topicId,
      createdAt: card.createdAt,
      nextReview: DateTime.now().add(Duration(days: newInterval)),
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
    );

    // Update in Firestore (need the document ID, but our ID is currently a field)
    // For now, search by ID or use the same ID as doc ID
    await _db.collection('flashcards').doc(userId).collection('items').doc(card.id).set(updatedCard.toMap());
    
    await fetchCards();
  }
}
