class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? registerNumber;
  final String? department;
  final int? year;
  final String? phoneNumber;
  final String role;
  final String? resumeUrl;
  final int profileCompletion;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.registerNumber,
    this.department,
    this.year,
    this.phoneNumber,
    required this.role,
    this.resumeUrl,
    this.profileCompletion = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      registerNumber: json['register_number'] as String?,
      department: json['department'] as String?,
      year: json['year'] as int?,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String,
      resumeUrl: json['resume_url'] as String?,
      profileCompletion: json['profile_completion'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'register_number': registerNumber,
      'department': department,
      'year': year,
      'phone_number': phoneNumber,
      'role': role,
      'resume_url': resumeUrl,
      'profile_completion': profileCompletion,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? registerNumber,
    String? department,
    int? year,
    String? phoneNumber,
    String? resumeUrl,
    int? profileCompletion,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      registerNumber: registerNumber ?? this.registerNumber,
      department: department ?? this.department,
      year: year ?? this.year,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
