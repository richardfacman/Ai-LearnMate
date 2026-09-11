class ExamModel {
  final String id;
  final String userId;
  final String name;
  final String subjectId;
  final DateTime date;
  final List<String> topicIds;
  final double readinessScore; // 0.0 to 1.0

  ExamModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.subjectId,
    required this.date,
    required this.topicIds,
    this.readinessScore = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'topicIds': topicIds,
      'readinessScore': readinessScore,
    };
  }

  factory ExamModel.fromMap(Map<String, dynamic> map) {
    return ExamModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      subjectId: map['subjectId'] ?? '',
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      topicIds: List<String>.from(map['topicIds'] ?? []),
      readinessScore: (map['readinessScore'] ?? 0.0).toDouble(),
    );
  }
}
