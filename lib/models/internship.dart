class Internship {
  final int id;
  final int studentId;
  final String? studentName;
  final String? regNo;
  final String companyName;
  final String role;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String status;
  final DateTime createdAt;

  final String? completionCertificateUrl;
  final List<String>? requiredSkills;

  // Getters for backward compatibility with UI
  String get title => role;
  String get company => companyName;
  String get duration => '${startDate.month}/${startDate.year} - ${endDate.month}/${endDate.year}';

  Internship({
    required this.id,
    required this.studentId,
    this.studentName,
    this.regNo,
    required this.companyName,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completionCertificateUrl,
    this.requiredSkills,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String?,
      regNo: json['reg_no'] as String?,
      companyName: json['company_name'] as String,
      role: json['role'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      description: json['description'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      completionCertificateUrl: json['certificate_file'] as String?,
      requiredSkills: json['required_skills'] != null 
          ? List<String>.from(json['required_skills'] as List) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'company_name': companyName,
      'role': role,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
