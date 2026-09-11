class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final int xp;
  final int level;
  final int streak;
  final int totalStudyTimeMinutes;
  final DateTime? lastStudyDate;
  final String? currentMood;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.totalStudyTimeMinutes = 0,
    this.lastStudyDate,
    this.currentMood,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'xp': xp,
      'level': level,
      'streak': streak,
      'totalStudyTimeMinutes': totalStudyTimeMinutes,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'currentMood': currentMood,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      xp: map['xp'] ?? 0,
      level: map['level'] ?? 1,
      streak: map['streak'] ?? 0,
      totalStudyTimeMinutes: map['totalStudyTimeMinutes'] ?? 0,
      lastStudyDate: map['lastStudyDate'] != null 
          ? DateTime.parse(map['lastStudyDate']) 
          : null,
      currentMood: map['currentMood'],
    );
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    int? xp,
    int? level,
    int? streak,
    int? totalStudyTimeMinutes,
    DateTime? lastStudyDate,
    String? currentMood,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      totalStudyTimeMinutes: totalStudyTimeMinutes ?? this.totalStudyTimeMinutes,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      currentMood: currentMood ?? this.currentMood,
    );
  }
}
