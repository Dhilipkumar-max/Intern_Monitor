class Skill {
  final String id;
  final String userId;
  final String skillName;
  final String skillLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  Skill({
    required this.id,
    required this.userId,
    required this.skillName,
    required this.skillLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      skillName: json['skill_name'] as String,
      skillLevel: json['skill_level'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'skill_name': skillName,
      'skill_level': skillLevel,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
