class Project {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? githubUrl;
  final String? liveUrl;
  final String? imageUrl;
  final List<String> technologies;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.githubUrl,
    this.liveUrl,
    this.imageUrl,
    required this.technologies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      userId: json['student_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      githubUrl: json['github_url'] as String?,
      liveUrl: json['live_url'] as String?,
      imageUrl: json['image_url'] as String?,
      technologies: json['technologies'] != null
          ? (json['technologies'] is String 
              ? (json['technologies'] as String).split(',').map((e) => e.trim()).toList()
              : List<String>.from(json['technologies'] as List))
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'github_url': githubUrl,
      'live_url': liveUrl,
      'image_url': imageUrl,
      'technologies': technologies,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
