import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/learning/flashcard_model.dart';
import 'ai/ai_provider_manager.dart';
import 'user_provider.dart';

class FlashcardProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<FlashcardModel> _cards = [];
  bool _isLoading = false;
  String? _selectedSubjectFilter;
  String? _selectedTopicFilter;

  List<FlashcardModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get selectedSubjectFilter => _selectedSubjectFilter;
  String? get selectedTopicFilter => _selectedTopicFilter;

  List<FlashcardModel> get filteredCards {
    return _cards.where((card) {
      if (_selectedSubjectFilter != null && card.subjectId != _selectedSubjectFilter) {
        return false;
      }
      if (_selectedTopicFilter != null && card.topicId != _selectedTopicFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<FlashcardModel> get dueNowCards => filteredCards.where((c) => c.isDueNow).toList();
  List<FlashcardModel> get dueTodayCards => filteredCards.where((c) => c.isDueToday).toList();
  List<FlashcardModel> get newCards => filteredCards.where((c) => c.status == "new").toList();
  List<FlashcardModel> get favoriteCards => filteredCards.where((c) => c.isFavorite).toList();

  void setSubjectFilter(String? subjectId) {
    _selectedSubjectFilter = subjectId;
    notifyListeners();
  }

  void setTopicFilter(String? topicId) {
    _selectedTopicFilter = topicId;
    notifyListeners();
  }

  Future<void> fetchCards() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db.collection('flashcards').doc(userId).collection('items').get();
      _cards = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FlashcardModel.fromMap(data);
      }).toList();

      _cards.sort((a, b) => a.nextReview.compareTo(b.nextReview));
    } catch (e) {
      debugPrint("Error fetching flashcards: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCard({
    required String question,
    required String answer,
    String? subjectId,
    String? topicId,
    List<String> tags = const [],
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final docRef = _db.collection('flashcards').doc(userId).collection('items').doc();
    final card = FlashcardModel(
      id: docRef.id,
      userId: userId,
      question: question,
      answer: answer,
      subjectId: subjectId,
      topicId: topicId,
      tags: tags,
      createdAt: DateTime.now(),
      nextReview: DateTime.now(),
    );

    await docRef.set(card.toMap());
    await fetchCards();
  }

  Future<void> editCard({
    required String cardId,
    required String question,
    required String answer,
    String? subjectId,
    String? topicId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.collection('flashcards').doc(userId).collection('items').doc(cardId).update({
      'question': question,
      'answer': answer,
      'subjectId': subjectId,
      'topicId': topicId,
    });
    await fetchCards();
  }

  Future<void> deleteCard(String cardId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _db.collection('flashcards').doc(userId).collection('items').doc(cardId).delete();
    _cards.removeWhere((c) => c.id == cardId);
    notifyListeners();
  }

  Future<void> toggleFavorite(FlashcardModel card) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final newFav = !card.isFavorite;
    await _db.collection('flashcards').doc(userId).collection('items').doc(card.id).update({
      'isFavorite': newFav,
    });
    await fetchCards();
  }

  /// SM-2 Spaced Repetition Review Implementation
  Future<void> reviewCard(FlashcardModel card, int quality, {UserProvider? userProvider}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // SM-2 Ease Factor calculation
    double newEaseFactor = card.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEaseFactor < 1.3) newEaseFactor = 1.3;

    int newInterval;
    String newStatus = "learning";

    if (quality < 3) {
      // Again (failed) -> Review immediately
      newInterval = 0;
    } else if (quality == 3) {
      // Hard
      newInterval = card.intervalDays == 0 ? 1 : (card.intervalDays * 1.2).round();
    } else if (quality == 4) {
      // Good
      if (card.intervalDays == 0) {
        newInterval = 1;
      } else if (card.intervalDays == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.intervalDays * newEaseFactor).round();
      }
    } else {
      // Easy
      if (card.intervalDays == 0) {
        newInterval = 4;
      } else {
        newInterval = (card.intervalDays * newEaseFactor * 1.4).round();
      }
      newStatus = "mastered";
    }

    if (newInterval > 365) newInterval = 365;

    final updatedCard = FlashcardModel(
      id: card.id,
      userId: userId,
      question: card.question,
      answer: card.answer,
      subjectId: card.subjectId,
      topicId: card.topicId,
      tags: card.tags,
      createdAt: card.createdAt,
      nextReview: DateTime.now().add(Duration(days: newInterval)),
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
      reviewCount: card.reviewCount + 1,
      isFavorite: card.isFavorite,
      status: newStatus,
    );

    await _db.collection('flashcards').doc(userId).collection('items').doc(card.id).set(updatedCard.toMap());

    // Award XP for completing a flashcard review
    if (userProvider != null) {
      await userProvider.updateXP(5);
      await userProvider.updateStreak();
    }

    await fetchCards();
  }

  /// AI Generation of Flashcards
  Future<int> generateAiCards({
    required String subject,
    required String topic,
    int count = 5,
    String difficulty = "Medium",
    String language = "English",
    String? optionalNotes,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 0;

    _isLoading = true;
    notifyListeners();

    try {
      final prompt = """
Act as an expert EdTech flashcard creator. Generate exactly $count flashcard study pairs for:
Subject: $subject
Topic: $topic
Difficulty: $difficulty
Language: $language
${optionalNotes != null && optionalNotes.isNotEmpty ? 'Reference Notes:\n$optionalNotes' : ''}

Return ONLY a valid JSON list of objects with this structure:
[
  {
    "question": "Front of the flashcard prompt/question",
    "answer": "Back of the flashcard concise answer/explanation"
  }
]
""";

      final content = await AiProviderManager().generateResponse(
        prompt: prompt,
        feature: AiFeature.flashcards,
      );

      final jsonStart = content.indexOf("[");
      final jsonEnd = content.lastIndexOf("]");
      if (jsonStart == -1 || jsonEnd == -1) return 0;

      final jsonString = content.substring(jsonStart, jsonEnd + 1);
      final List parsed = jsonDecode(jsonString);

      int addedCount = 0;
      for (var item in parsed) {
        final q = item['question']?.toString() ?? item['front'] ?? '';
        final a = item['answer']?.toString() ?? item['back'] ?? '';
        if (q.isNotEmpty && a.isNotEmpty) {
          final docRef = _db.collection('flashcards').doc(userId).collection('items').doc();
          final card = FlashcardModel(
            id: docRef.id,
            userId: userId,
            question: q,
            answer: a,
            subjectId: subject,
            topicId: topic,
            tags: [subject, topic, difficulty],
            createdAt: DateTime.now(),
            nextReview: DateTime.now(),
          );
          await docRef.set(card.toMap());
          addedCount++;
        }
      }

      await fetchCards();
      return addedCount;
    } catch (e) {
      debugPrint("Error generating AI flashcards: $e");
      return 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
