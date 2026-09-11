enum SessionType { learn, practice, revision, quiz, flashcards, rest }

class StudySessionModel {
  final String id;
  final String topicId;
  final String topicName;
  final SessionType type;
  final int durationMinutes;
  final DateTime scheduledTime;
  bool isCompleted;

  StudySessionModel({
    required this.id,
    required this.topicId,
    required this.topicName,
    required this.type,
    required this.durationMinutes,
    required this.scheduledTime,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'topicName': topicName,
      'type': type.name,
      'durationMinutes': durationMinutes,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory StudySessionModel.fromMap(Map<String, dynamic> map) {
    return StudySessionModel(
      id: map['id'] ?? '',
      topicId: map['topicId'] ?? '',
      topicName: map['topicName'] ?? '',
      type: SessionType.values.firstWhere((e) => e.name == map['type'], orElse: () => SessionType.learn),
      durationMinutes: map['durationMinutes'] ?? 30,
      scheduledTime: map['scheduledTime'] != null ? DateTime.parse(map['scheduledTime']) : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
