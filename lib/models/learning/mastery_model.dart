class MasteryModel {
  final String topicId;
  final String userId;
  final double score; // 0.0 to 1.0
  final DateTime updatedAt;
  final int correctAnswers;
  final int totalAttempts;

  MasteryModel({
    required this.topicId,
    required this.userId,
    this.score = 0.0,
    required this.updatedAt,
    this.correctAnswers = 0,
    this.totalAttempts = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'topicId': topicId,
      'userId': userId,
      'score': score,
      'updatedAt': updatedAt.toIso8601String(),
      'correctAnswers': correctAnswers,
      'totalAttempts': totalAttempts,
    };
  }

  factory MasteryModel.fromMap(Map<String, dynamic> map) {
    return MasteryModel(
      topicId: map['topicId'] ?? '',
      userId: map['userId'] ?? '',
      score: (map['score'] ?? 0.0).toDouble(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : DateTime.now(),
      correctAnswers: map['correctAnswers'] ?? 0,
      totalAttempts: map['totalAttempts'] ?? 0,
    );
  }
}
