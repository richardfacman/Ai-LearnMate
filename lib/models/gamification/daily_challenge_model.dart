class DailyChallengeModel {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final int currentValue;
  final int xpReward;
  final bool isCompleted;
  final DateTime date;

  DailyChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    this.currentValue = 0,
    required this.xpReward,
    this.isCompleted = false,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'date': date.toIso8601String(),
    };
  }

  factory DailyChallengeModel.fromMap(Map<String, dynamic> map) {
    return DailyChallengeModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      targetValue: map['targetValue'] ?? 1,
      currentValue: map['currentValue'] ?? 0,
      xpReward: map['xpReward'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
