class SubjectModel {
  final String id;
  final String name;
  final String? icon;
  final double overallMastery; // 0.0 to 1.0

  SubjectModel({
    required this.id,
    required this.name,
    this.icon,
    this.overallMastery = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'overallMastery': overallMastery,
    };
  }

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'],
      overallMastery: (map['overallMastery'] ?? 0.0).toDouble(),
    );
  }
}
