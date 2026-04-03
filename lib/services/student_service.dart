import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/internship.dart';
import '../models/notification.dart';
import '../models/skill.dart';
import '../models/project.dart';
import '../models/certificate.dart';

class StudentService {
  // Get student internships
  Future<List<Internship>> getMyInternships(int studentId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/internships/student/$studentId'),
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

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats(int studentId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/students/stats/$studentId'),
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

  // Submit new internship
  Future<bool> submitInternship(Map<String, dynamic> internshipData) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/internships'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode(internshipData),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Get notifications
  Future<List<AppNotification>> getNotifications(int studentId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/notifications/student/$studentId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => AppNotification.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read'),
        headers: ApiConfig.getHeaders(token),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get all skills
  Future<List<Skill>> getAllSkills() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/skills'),
        headers: ApiConfig.getHeaders(null),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Skill.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get student's skills
  Future<List<Skill>> getSkills(int studentId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/skills/student/$studentId'),
        headers: ApiConfig.getHeaders(token),
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((item) => Skill.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Add skill
  Future<bool> addSkill(int studentId, String skillName, String level) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/skills/add'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_id': studentId,
          'skill_name': skillName,
          'level': level,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Update skill level
  Future<bool> updateSkill(int studentId, int skillId, String level) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/skills/update'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_id': studentId,
          'skill_id': skillId,
          'level': level,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Delete skill
  Future<bool> deleteSkill(int skillId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/skills/$skillId'),
        headers: ApiConfig.getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Upload resume
  Future<String?> uploadResume(int userId, String fileName, List<int> fileBytes) async {
    try {
      final token = await ApiConfig.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/resume'),
      );
      
      request.headers.addAll(ApiConfig.getHeaders(token));
      request.fields['studentId'] = userId.toString();
      
      request.files.add(http.MultipartFile.fromBytes(
        'resume',
        fileBytes,
        filename: fileName,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get student internships (alias for getMyInternships)
  Future<List<Internship>> getInternships(int studentId) => getMyInternships(studentId);

  // Update internship
  Future<bool> updateInternship({
    required int internshipId,
    required String title,
    required String company,
    required String role,
    required String duration,
    String? certificateUrl,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/internships/$internshipId'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'role': title, // title maps to role in schema
          'company_name': company,
          'description': role, // role maps to description or vice versa depending on UI usage
          'start_date': '2023-01-01', // Placeholder or parse from duration
          'end_date': '2023-01-01',
          'certificate_file': certificateUrl,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Add internship
  Future<bool> addInternship({
    required int userId,
    required String title,
    required String company,
    required String role,
    required String duration,
    String? certificateUrl,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/internships'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_id': userId,
          'role': title,
          'company_name': company,
          'description': role,
          'start_date': '2023-01-01',
          'end_date': '2023-01-01',
          'certificate_file': certificateUrl,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Delete internship
  Future<bool> deleteInternship(int id) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/internships/$id'),
        headers: ApiConfig.getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get certificates
  Future<List<Certificate>> getCertificates(int studentId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/certificates/student/$studentId'),
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

  // Upload certificate file
  Future<String?> uploadCertificateFile(int userId, String fileName, List<int> bytes) async {
    try {
      final token = await ApiConfig.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/certificate'),
      );
      
      request.headers.addAll(ApiConfig.getHeaders(token));
      request.fields['studentId'] = userId.toString();
      
      request.files.add(http.MultipartFile.fromBytes(
        'certificate',
        bytes,
        filename: fileName,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return jsonDecode(response.body)['url'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Upload certificate record
  Future<bool> uploadCertificate({
    required int userId,
    required String certificateType,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/certificates'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_id': userId,
          'certificate_type': certificateType,
          'file_url': fileUrl,
          'file_name': fileName,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Update certificate
  Future<bool> updateCertificate({
    required int certificateId,
    required String certificateType,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/certificates/$certificateId'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({'certificate_type': certificateType}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Delete certificate
  Future<bool> deleteCertificate(int id) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/certificates/$id'),
        headers: ApiConfig.getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Project methods
  Future<List<Project>> getProjects(int userId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/projects?student_id=$userId'),
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

  Future<bool> addProject({
    required int userId,
    required String title,
    required String description,
    String? githubUrl,
    String? liveUrl,
    required List<String> technologies,
  }) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/projects'),
        headers: ApiConfig.getHeaders(token),
        body: jsonEncode({
          'student_id': userId,
          'title': title,
          'description': description,
          'github_url': githubUrl,
          'live_url': liveUrl,
          'technologies': technologies.join(','),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProject(int projectId) async {
    try {
      final token = await ApiConfig.getToken();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/projects/$projectId'),
        headers: ApiConfig.getHeaders(token),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadCompletionCertificate(int internshipId, String url) async {
    return false;
  }
}
