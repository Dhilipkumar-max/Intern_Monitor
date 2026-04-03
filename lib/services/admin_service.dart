import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';
import '../models/project.dart';
import '../models/certificate.dart';

class AdminService {
  // Get all internships for admin
  Future<List<Internship>> getAllInternships() async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/internships/all'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Internship.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get admin dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // Update internship status
  Future<bool> updateInternshipStatus(int internshipId, String status) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/internships/$internshipId/status'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get all students
  Future<List<UserProfile>> getAllStudents() async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/students'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => UserProfile.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Search students by skill
  Future<List<Map<String, dynamic>>> searchStudentsBySkill({
    required String skillName,
    String? skillLevel,
    String? department,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      String query = 'skill_name=$skillName';
      if (skillLevel != null) query += '&skill_level=$skillLevel';
      if (department != null) query += '&department=$department';

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/search-students?$query'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => {
          'student': UserProfile.fromJson(item['student']),
          'skill_level': item['skill_level'],
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Certificate verification
  Future<List<Certificate>> getPendingCertificates() async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/certificates/pending'),
        headers: ApiConfig.getHeaders(token),
      );
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Certificate.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> verifyCertificate(int id, int adminId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/certificates/$id/verify'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'admin_id': adminId}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectCertificate(int id, int adminId, String reason) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/certificates/$id/reject'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'admin_id': adminId,
          'reason': reason,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Student management
  Future<bool> addStudent({
    required String name,
    required String email,
    required String registerNumber,
    required String department,
    required int year,
    required String initialPassword,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/student/register'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'name': name,
          'email': email,
          'reg_no': registerNumber,
          'department_name': department,
          'year': year,
          'password': initialPassword,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> bulkAddStudents(List<Map<String, dynamic>> students) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/student/bulk-register'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'students': students}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return {'success': 0, 'failed': students.length};
    } catch (e) {
      return {'success': 0, 'failed': students.length};
    }
  }
  
  // Internship assignment
  Future<bool> assignInternshipToStudents({
    required String title,
    required String company,
    required String role,
    required String duration,
    required List<String> requiredSkills,
    required List<int> studentIds,
    required int adminId,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/assign-internship'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_ids': studentIds,
          'title': title,
          'company': company,
          'role': role,
          'duration': duration,
          'required_skills': requiredSkills.join(','),
          'admin_id': adminId,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Get report statistics
  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
        headers: ApiConfig.getHeaders(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      return {};
    }
  }


  // Notification
  Future<bool> sendNotification({
    required int studentId,
    required String title,
    required String message,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_id': studentId,
          'title': title,
          'message': message,
          'type': 'admin_message',
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Register a new admin
  Future<bool> createAdmin(Map<String, dynamic> adminData) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/admin/register'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(adminData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Helper for project details in admin view
  Future<List<Project>> getStudentProjects(int studentId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/projects?student_id=$studentId'),
        headers: ApiConfig.getHeaders(token),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Project.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
