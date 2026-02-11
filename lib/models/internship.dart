class Internship {
  final String id;
  final String? userId;
  final String title;
  final String company;
  final String? role;
  final String? duration;
  final String status;
  final String? assignedByAdmin;
  final List<String>? requiredSkills;
  final String? completionCertificateUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Internship({
    required this.id,
    this.userId,
    required this.title,
    required this.company,
    this.role,
    this.duration,
    required this.status,
    this.assignedByAdmin,
    this.requiredSkills,
    this.completionCertificateUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      title: json['title'] as String,
      company: json['company'] as String,
      role: json['role'] as String?,
      duration: json['duration'] as String?,
      status: json['status'] as String,
      assignedByAdmin: json['assigned_by_admin'] as String?,
      requiredSkills: json['required_skills'] != null
          ? List<String>.from(json['required_skills'] as List)
          : null,
      completionCertificateUrl: json['completion_certificate_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'company': company,
      'role': role,
      'duration': duration,
      'status': status,
      'assigned_by_admin': assignedByAdmin,
      'required_skills': requiredSkills,
      'completion_certificate_url': completionCertificateUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
