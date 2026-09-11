class FlashcardModel {
  final String id;
  final String userId;
  final String question;
  final String answer;
  final String? topicId;
  final DateTime createdAt;
  final DateTime nextReview;
  final int intervalDays;
  final double easeFactor; // SM-2 algorithm parameter

  FlashcardModel({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    this.topicId,
    required this.createdAt,
    required this.nextReview,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'question': question,
      'answer': answer,
      'topicId': topicId,
      'createdAt': createdAt.toIso8601String(),
      'nextReview': nextReview.toIso8601String(),
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      topicId: map['topicId'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      nextReview: map['nextReview'] != null ? DateTime.parse(map['nextReview']) : DateTime.now(),
      intervalDays: map['intervalDays'] ?? 0,
      easeFactor: (map['easeFactor'] ?? 2.5).toDouble(),
    );
  }
}
