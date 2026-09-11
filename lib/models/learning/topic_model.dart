class TopicModel {
  final String id;
  final String subjectId;
  final String name;
  final String? parentId; // For hierarchical topics
  final double mastery; // 0.0 to 1.0
  final DateTime? lastReviewed;

  TopicModel({
    required this.id,
    required this.subjectId,
    required this.name,
    this.parentId,
    this.mastery = 0.0,
    this.lastReviewed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subjectId': subjectId,
      'name': name,
      'parentId': parentId,
      'mastery': mastery,
      'lastReviewed': lastReviewed?.toIso8601String(),
    };
  }

  factory TopicModel.fromMap(Map<String, dynamic> map) {
    return TopicModel(
      id: map['id'] ?? '',
      subjectId: map['subjectId'] ?? '',
      name: map['name'] ?? '',
      parentId: map['parentId'],
      mastery: (map['mastery'] ?? 0.0).toDouble(),
      lastReviewed: map['lastReviewed'] != null 
          ? DateTime.parse(map['lastReviewed']) 
          : null,
    );
  }
}
