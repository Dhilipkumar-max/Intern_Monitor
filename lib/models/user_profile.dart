class UserProfile {
  final int id;
  final String? regNo; // internal use
  final String? registerNumber; // for UI compatibility
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? department;
  final int? year;
  final List<String>? skills;
  final int? profileCompletion;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? resumeUrl;

  UserProfile({
    required this.id,
    this.regNo,
    this.registerNumber,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.department,
    this.year,
    this.skills,
    this.profileCompletion,
    this.githubUrl,
    this.linkedinUrl,
    this.resumeUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      regNo: json['reg_no'] as String?,
      registerNumber: json['reg_no'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone'] as String?,
      role: json['role'] as String,
      department: json['department_name'] as String?,
      year: json['year'] as int?,
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
      profileCompletion: json['profile_completion'] as int? ?? 0,
      githubUrl: json['github_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      resumeUrl: json['resume_file'] as String?, // Map from resumes table if joined
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reg_no': regNo,
      'name': name,
      'email': email,
      'phone': phoneNumber,
      'role': role,
      'department_name': department,
      'year': year,
      'skills': skills,
      'profile_completion': profileCompletion,
      'github_url': githubUrl,
      'linkedin_url': linkedinUrl,
      'resume_file': resumeUrl,
    };
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? regNo,
    String? phoneNumber,
    String? department,
    int? year,
    List<String>? skills,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      regNo: regNo ?? this.regNo,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role,
      department: department ?? this.department,
      year: year ?? this.year,
      skills: skills ?? this.skills,
    );
  }
}
