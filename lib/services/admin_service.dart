import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';
import '../models/skill.dart';
import '../models/internship.dart';
import '../models/certificate.dart';

class AdminService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // ========== STUDENT MANAGEMENT ==========
  Future<List<UserProfile>> getAllStudents({
    String? department,
    int? year,
    String? internshipStatus,
  }) async {
    try {
      var query = _supabase
          .from('profiles')
          .select()
          .eq('role', 'student');

      if (department != null && department.isNotEmpty) {
        query = query.eq('department', department);
      }

      if (year != null) {
        query = query.eq('year', year);
      }

      final data = await query.order('name', ascending: true);

      List<UserProfile> students = (data as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();

      // Filter by internship status if provided
      if (internshipStatus != null && internshipStatus.isNotEmpty) {
        final studentsWithInternships = <UserProfile>[];
        for (var student in students) {
          final internships = await getStudentInternships(student.id);
          if (internshipStatus == 'Not Assigned' && internships.isEmpty) {
            studentsWithInternships.add(student);
          } else if (internships.isNotEmpty && internships.first.status == internshipStatus) {
            studentsWithInternships.add(student);
          }
        }
        return studentsWithInternships;
      }

      return students;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addStudent({
    required String name,
    required String email,
    required String registerNumber,
    required String department,
    required int year,
    required String initialPassword,
  }) async {
    try {
      debugPrint('Admin attempt to add TRUE student account: $email');
      
      // Call the secure RPC function to create Auth + Profile
      final result = await _supabase.rpc('create_student_auth', params: {
        'p_email': email,
        'p_password': initialPassword,
        'p_name': name,
        'p_reg_number': registerNumber,
        'p_dept': department,
        'p_year': year,
      });

      if (result['success'] == true) {
        debugPrint('Student account created successfully via RPC: $email');
        return true;
      } else {
        debugPrint('RPC Error creating student: ${result['error']}');
        return false;
      }
    } catch (e) {
      debugPrint('Error in AdminService.addStudent: $e');
      return false;
    }
  }

  Future<Map<String, int>> bulkAddStudents(List<Map<String, dynamic>> students) async {
    int successCount = 0;
    int failCount = 0;

    for (var student in students) {
      final success = await addStudent(
        name: student['name'],
        email: student['email'],
        registerNumber: student['register_number'],
        department: student['department'],
        year: student['year'],
        initialPassword: student['password'],
      );
      if (success) {
        successCount++;
      } else {
        failCount++;
      }
    }

    return {
      'success': successCount,
      'failed': failCount,
    };
  }

  Future<UserProfile?> getStudentProfile(String studentId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', studentId)
          .single();

      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Skill>> getStudentSkills(String studentId) async {
    try {
      final data = await _supabase
          .from('skills')
          .select()
          .eq('user_id', studentId);

      return (data as List).map((json) => Skill.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Internship>> getStudentInternships(String studentId) async {
    try {
      final data = await _supabase
          .from('internships')
          .select()
          .eq('user_id', studentId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Internship.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Certificate>> getStudentCertificates(String studentId) async {
    try {
      final data = await _supabase
          .from('certificates')
          .select()
          .eq('user_id', studentId)
          .order('created_at', ascending: false);

      return (data as List).map((json) => Certificate.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // ========== SKILL-BASED SEARCH ==========
  Future<List<Map<String, dynamic>>> searchStudentsBySkill({
    String? skillName,
    String? skillLevel,
    String? department,
    int? year,
  }) async {
    try {
      var query = _supabase.from('skills').select('*, profiles!inner(*)');

      if (skillName != null && skillName.isNotEmpty) {
        query = query.ilike('skill_name', '%$skillName%');
      }

      if (skillLevel != null && skillLevel.isNotEmpty) {
        query = query.eq('skill_level', skillLevel);
      }

      final data = await query;

      List<Map<String, dynamic>> results = [];
      for (var item in data as List) {
        final profile = item['profiles'];
        if (department != null && profile['department'] != department) continue;
        if (year != null && profile['year'] != year) continue;

        results.add({
          'student': UserProfile.fromJson(profile),
          'skill': Skill.fromJson(item),
        });
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  // ========== INTERNSHIP ASSIGNMENT ==========
  Future<bool> createInternship({
    required String title,
    required String company,
    required String role,
    required String duration,
    required List<String> requiredSkills,
    required String adminId,
  }) async {
    try {
      await _supabase.from('internships').insert({
        'title': title,
        'company': company,
        'role': role,
        'duration': duration,
        'status': 'Not Done',
        'required_skills': requiredSkills,
        'assigned_by_admin': adminId,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> assignInternship({
    required String internshipId,
    required List<String> studentIds,
    required String adminId,
  }) async {
    try {
      // Get internship details
      final internshipData = await _supabase
          .from('internships')
          .select()
          .eq('id', internshipId)
          .single();

      final internship = Internship.fromJson(internshipData);

      // Create internship assignments for each student
      for (var studentId in studentIds) {
        await _supabase.from('internships').insert({
          'user_id': studentId,
          'title': internship.title,
          'company': internship.company,
          'role': internship.role,
          'duration': internship.duration,
          'status': 'Assigned',
          'required_skills': internship.requiredSkills,
          'assigned_by_admin': adminId,
        });

        // Create notification
        await _supabase.from('notifications').insert({
          'user_id': studentId,
          'title': 'Internship Assigned',
          'message': 'You have been assigned an internship at ${internship.company}',
          'type': 'internship_assigned',
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> assignInternshipToStudents({
    required String title,
    required String company,
    required String role,
    required String duration,
    required List<String> requiredSkills,
    required List<String> studentIds,
    required String adminId,
  }) async {
    try {
      for (var studentId in studentIds) {
        await _supabase.from('internships').insert({
          'user_id': studentId,
          'title': title,
          'company': company,
          'role': role,
          'duration': duration,
          'status': 'Assigned',
          'required_skills': requiredSkills,
          'assigned_by_admin': adminId,
        });

        // Create notification
        await _supabase.from('notifications').insert({
          'user_id': studentId,
          'title': 'Internship Assigned',
          'message': 'You have been assigned an internship at $company',
          'type': 'internship_assigned',
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== CERTIFICATE VERIFICATION ==========
  Future<List<Certificate>> getPendingCertificates() async {
    try {
      final data = await _supabase
          .from('certificates')
          .select()
          .eq('verification_status', 'Pending')
          .order('created_at', ascending: true);

      return (data as List).map((json) => Certificate.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> verifyCertificate(String certificateId, String adminId) async {
    try {
      await _supabase.from('certificates').update({
        'verification_status': 'Verified',
        'verified_by': adminId,
      }).eq('id', certificateId);

      // Get certificate to send notification
      final certData = await _supabase
          .from('certificates')
          .select()
          .eq('id', certificateId)
          .single();

      final cert = Certificate.fromJson(certData);

      // Create notification
      await _supabase.from('notifications').insert({
        'user_id': cert.userId,
        'title': 'Certificate Verified',
        'message': 'Your ${cert.certificateType} certificate has been verified',
        'type': 'certificate_verified',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectCertificate(String certificateId, String adminId, String remark) async {
    try {
      await _supabase.from('certificates').update({
        'verification_status': 'Rejected',
        'verified_by': adminId,
        'admin_remark': remark,
      }).eq('id', certificateId);

      // Get certificate to send notification
      final certData = await _supabase
          .from('certificates')
          .select()
          .eq('id', certificateId)
          .single();

      final cert = Certificate.fromJson(certData);

      // Create notification
      await _supabase.from('notifications').insert({
        'user_id': cert.userId,
        'title': 'Certificate Rejected',
        'message': 'Your ${cert.certificateType} certificate was rejected. Reason: $remark',
        'type': 'certificate_rejected',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendNotification({
    required String studentId,
    required String title,
    required String message,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': studentId,
        'title': title,
        'message': message,
        'type': 'admin_message',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ========== DASHBOARD STATS ==========
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final studentsData = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'student');

      final totalStudents = (studentsData as List).length;

      final internshipsData = await _supabase
          .from('internships')
          .select();

      final studentsWithInternships = (internshipsData as List)
          .where((i) => i['user_id'] != null)
          .map((i) => i['user_id'])
          .toSet()
          .length;

      final studentsWithoutInternships = totalStudents - studentsWithInternships;

      final completedInternships = (internshipsData as List)
          .where((i) => i['status'] == 'Completed')
          .length;

      final pendingCertificates = await getPendingCertificates();

      return {
        'totalStudents': totalStudents,
        'studentsWithoutInternships': studentsWithoutInternships,
        'completedInternships': completedInternships,
        'pendingCertificates': pendingCertificates.length,
      };
    } catch (e) {
      return {
        'totalStudents': 0,
        'studentsWithoutInternships': 0,
        'completedInternships': 0,
        'pendingCertificates': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getReportStats() async {
    try {
      final students = await _supabase.from('profiles').select().eq('role', 'student');
      final internships = await _supabase.from('internships').select();

      // Department wise distribution
      Map<String, int> deptStats = {};
      for (var student in students as List) {
        final dept = student['department'] ?? 'Other';
        deptStats[dept] = (deptStats[dept] ?? 0) + 1;
      }

      // Year wise distribution
      Map<int, int> yearStats = {};
      for (var student in students) {
        final year = student['year'] ?? 0;
        yearStats[year] = (yearStats[year] ?? 0) + 1;
      }

      // Internship status distribution
      Map<String, int> statusStats = {
        'Completed': 0,
        'Ongoing': 0,
        'Assigned': 0,
        'Not Done': 0,
      };
      for (var internship in internships as List) {
        final status = internship['status'] ?? 'Unknown';
        if (statusStats.containsKey(status)) {
          statusStats[status] = statusStats[status]! + 1;
        }
      }

      return {
        'deptStats': deptStats,
        'yearStats': yearStats,
        'statusStats': statusStats,
        'totalStudents': students.length,
        'totalInternships': internships.length,
      };
    } catch (e) {
      return {};
    }
  }
}
