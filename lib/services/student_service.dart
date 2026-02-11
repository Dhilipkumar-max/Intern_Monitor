import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/skill.dart';
import '../models/internship.dart';
import '../models/certificate.dart';
import '../models/notification.dart';

class StudentService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ========== SKILLS ==========
  Future<List<Skill>> getSkills(String userId) async {
    try {
      final data = await _supabase
          .from('skills')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Skill.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching skills: $e');
      return [];
    }
  }

  Future<bool> addSkill(String userId, String skillName, String skillLevel) async {
    try {
      await _supabase.from('skills').insert({
        'user_id': userId,
        'skill_name': skillName,
        'skill_level': skillLevel,
      });
      return true;
    } catch (e) {
      debugPrint('Error adding skill: $e');
      return false;
    }
  }

  Future<bool> updateSkill(String skillId, String skillName, String skillLevel) async {
    try {
      await _supabase.from('skills').update({
        'skill_name': skillName,
        'skill_level': skillLevel,
      }).eq('id', skillId);
      return true;
    } catch (e) {
      debugPrint('Error updating skill: $e');
      return false;
    }
  }

  Future<bool> deleteSkill(String skillId) async {
    try {
      await _supabase.from('skills').delete().eq('id', skillId);
      return true;
    } catch (e) {
      debugPrint('Error deleting skill: $e');
      return false;
    }
  }

  // ========== INTERNSHIPS ==========
  Future<List<Internship>> getInternships(String userId) async {
    try {
      final data = await _supabase
          .from('internships')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Internship.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching internships: $e');
      return [];
    }
  }

  Future<bool> updateInternshipStatus(String internshipId, String status) async {
    try {
      await _supabase.from('internships').update({
        'status': status,
      }).eq('id', internshipId);
      return true;
    } catch (e) {
      debugPrint('Error updating internship status: $e');
      return false;
    }
  }

  Future<bool> uploadCompletionCertificate(String internshipId, String certificateUrl) async {
    try {
      await _supabase.from('internships').update({
        'completion_certificate_url': certificateUrl,
        'status': 'Completed',
      }).eq('id', internshipId);
      return true;
    } catch (e) {
      debugPrint('Error uploading completion certificate: $e');
      return false;
    }
  }

  Future<bool> addInternship({
    required String userId,
    required String title,
    required String company,
    required String role,
    required String duration,
    String? certificateUrl,
  }) async {
    try {
      debugPrint('Adding internship for user: $userId');
      await _supabase.from('internships').insert({
        'user_id': userId,
        'title': title,
        'company': company,
        'role': role,
        'duration': duration,
        'completion_certificate_url': certificateUrl,
        'status': certificateUrl != null ? 'Completed' : 'Ongoing',
        'required_skills': [],
      });
      return true;
    } catch (e) {
      debugPrint('Error in StudentService.addInternship: $e');
      if (e is PostgrestException) {
        debugPrint('Postgrest Error: ${e.message}, Hint: ${e.hint}, Details: ${e.details}');
      }
      return false;
    }
  }

  Future<bool> updateInternship({
    required String internshipId,
    required String title,
    required String company,
    required String role,
    required String duration,
    String? certificateUrl,
  }) async {
    try {
      await _supabase.from('internships').update({
        'title': title,
        'company': company,
        'role': role,
        'duration': duration,
        'completion_certificate_url': certificateUrl,
        'status': certificateUrl != null ? 'Completed' : 'Ongoing',
      }).eq('id', internshipId);
      return true;
    } catch (e) {
      debugPrint('Error updating internship: $e');
      return false;
    }
  }

  Future<bool> deleteInternship(String internshipId) async {
    try {
      await _supabase.from('internships').delete().eq('id', internshipId);
      return true;
    } catch (e) {
      debugPrint('Error deleting internship: $e');
      return false;
    }
  }

  Future<bool> deleteCertificate(String certificateId) async {
    try {
      await _supabase.from('certificates').delete().eq('id', certificateId);
      return true;
    } catch (e) {
      debugPrint('Error deleting certificate: $e');
      return false;
    }
  }

  // ========== CERTIFICATES ==========
  Future<List<Certificate>> getCertificates(String userId) async {
    try {
      final data = await _supabase
          .from('certificates')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Certificate.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching certificates: $e');
      return [];
    }
  }

  Future<bool> uploadCertificate({
    required String userId,
    required String certificateType,
    required String fileUrl,
    required String fileName,
  }) async {
    try {
      await _supabase.from('certificates').insert({
        'user_id': userId,
        'certificate_type': certificateType,
        'file_url': fileUrl,
        'file_name': fileName,
        'verification_status': 'Pending',
      });
      return true;
    } catch (e) {
      debugPrint('Error uploading certificate record: $e');
      return false;
    }
  }

  Future<bool> updateCertificate({
    required String certificateId,
    required String certificateType,
  }) async {
    try {
      await _supabase.from('certificates').update({
        'certificate_type': certificateType,
      }).eq('id', certificateId);
      return true;
    } catch (e) {
      debugPrint('Error updating certificate: $e');
      return false;
    }
  }

  // ========== NOTIFICATIONS ==========
  Future<List<AppNotification>> getNotifications(String userId) async {
    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => AppNotification.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);

      return (data as List).length;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _supabase.from('notifications').update({
        'is_read': true,
      }).eq('id', notificationId);
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  // ========== STORAGE ==========
  Future<String?> uploadResume(String userId, String filePath, List<int> fileBytes) async {
    try {
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_resume.pdf';
      await _supabase.storage.from('resumes').uploadBinary(
        fileName,
        Uint8List.fromList(fileBytes),
        fileOptions: const FileOptions(upsert: true),
      );

      final url = _supabase.storage.from('resumes').getPublicUrl(fileName);
      return url;
    } catch (e) {
      debugPrint('Error uploading resume file: $e');
      return null;
    }
  }

  Future<String?> uploadCertificateFile(String userId, String filePath, List<int> fileBytes) async {
    try {
      final extension = filePath.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_certificate.$extension';
      await _supabase.storage.from('certificates').uploadBinary(
        fileName,
        Uint8List.fromList(fileBytes),
        fileOptions: const FileOptions(upsert: true),
      );

      final url = _supabase.storage.from('certificates').getPublicUrl(fileName);
      return url;
    } catch (e) {
      debugPrint('Error uploading certificate file: $e');
      return null;
    }
  }

  // ========== DASHBOARD STATS ==========
  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    try {
      final skills = await getSkills(userId);
      final internships = await getInternships(userId);
      final certificates = await getCertificates(userId);
      final notifications = await getNotifications(userId);

      String internshipStatus = 'Not Assigned';
      if (internships.isNotEmpty) {
        internshipStatus = internships.first.status;
      }

      return {
        'skillsCount': skills.length,
        'certificatesCount': certificates.length,
        'internshipStatus': internshipStatus,
        'unreadNotifications': notifications.where((n) => !n.isRead).length,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'skillsCount': 0,
        'certificatesCount': 0,
        'internshipStatus': 'Not Assigned',
        'unreadNotifications': 0,
      };
    }
  }
}
