class MistakeModel {
  final String id;
  final String userId;
  final String question;
  final String studentAnswer;
  final String correctAnswer;
  final String explanation;
  final String topicId;
  final DateTime createdAt;
  final int occurrenceCount;

  MistakeModel({
    required this.id,
    required this.userId,
    required this.question,
    required this.studentAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.topicId,
    required this.createdAt,
    this.occurrenceCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'question': question,
      'studentAnswer': studentAnswer,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'topicId': topicId,
      'createdAt': createdAt.toIso8601String(),
      'occurrenceCount': occurrenceCount,
    };
  }

  factory MistakeModel.fromMap(Map<String, dynamic> map) {
    return MistakeModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      question: map['question'] ?? '',
      studentAnswer: map['studentAnswer'] ?? '',
      correctAnswer: map['correctAnswer'] ?? '',
      explanation: map['explanation'] ?? '',
      topicId: map['topicId'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      occurrenceCount: map['occurrenceCount'] ?? 1,
    );
  }
}
