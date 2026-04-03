class AppNotification {
  final int id;
  final int studentId;
  final String message;
  final String status;
  final DateTime createdAt;
  final String? type;
  final String? title;

  bool get isRead => status == 'Read';

  AppNotification({
    required this.id,
    required this.studentId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.type,
    this.title,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      studentId: json['student_id'] as int,
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String?,
      title: json['title'] as String? ?? 'Notification',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
