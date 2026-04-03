class Skill {
  final int id;
  final String skillName;
  final String? skillLevel;

  Skill({
    required this.id,
    required this.skillName,
    this.skillLevel,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as int,
      skillName: json['skill_name'] as String,
      skillLevel: json['level'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill_name': skillName,
    };
  }
}
