class FlashcardModel {
  final String id;
  final String userId;
  final String question; // Front
  final String answer;   // Back
  final String? subjectId;
  final String? topicId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime nextReview;
  final int intervalDays;
  final double easeFactor; // SM-2 parameter
  final int reviewCount;
  final bool isFavorite;
  final String status; // "new", "learning", "mastered"

  FlashcardModel({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    this.subjectId,
    this.topicId,
    this.tags = const [],
    required this.createdAt,
    required this.nextReview,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    this.reviewCount = 0,
    this.isFavorite = false,
    this.status = "new",
  });

  bool get isDueNow => nextReview.isBefore(DateTime.now());
  bool get isDueToday {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return nextReview.isBefore(todayEnd);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'question': question,
      'answer': answer,
      'subjectId': subjectId,
      'topicId': topicId,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'nextReview': nextReview.toIso8601String(),
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'reviewCount': reviewCount,
      'isFavorite': isFavorite,
      'status': status,
    };
  }

  factory FlashcardModel.fromMap(Map<String, dynamic> map) {
    return FlashcardModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      question: map['question'] ?? map['front'] ?? '',
      answer: map['answer'] ?? map['back'] ?? '',
      subjectId: map['subjectId'],
      topicId: map['topicId'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : const [],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      nextReview: map['nextReview'] != null ? DateTime.parse(map['nextReview']) : DateTime.now(),
      intervalDays: map['intervalDays'] ?? 0,
      easeFactor: (map['easeFactor'] ?? 2.5).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isFavorite: map['isFavorite'] ?? false,
      status: map['status'] ?? "new",
    );
  }
}
