class Certificate {
  final int id;
  final int userId;
  final String certificateType;
  final String fileUrl;
  final String fileName;
  final String verificationStatus;
  final String? adminRemark;
  final int? verifiedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.certificateType,
    required this.fileUrl,
    required this.fileName,
    required this.verificationStatus,
    this.adminRemark,
    this.verifiedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int,
      userId: json['student_id'] as int,
      certificateType: json['certificate_type'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      verificationStatus: json['status'] as String,
      adminRemark: json['admin_remark'] as String?,
      verifiedBy: json['verified_by'] as int?,
      createdAt: DateTime.parse((json['uploaded_at'] ?? json['created_at']) as String),
      updatedAt: DateTime.parse((json['uploaded_at'] ?? json['updated_at'] ?? json['created_at']) as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'certificate_type': certificateType,
      'file_url': fileUrl,
      'file_name': fileName,
      'verification_status': verificationStatus,
      'admin_remark': adminRemark,
      'verified_by': verifiedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
