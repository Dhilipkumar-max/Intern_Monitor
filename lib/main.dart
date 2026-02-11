import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/student_profile_screen.dart';
import 'screens/student/student_skills_screen.dart';
import 'screens/student/resume_upload_screen.dart';
import 'screens/student/certificates_screen.dart';
import 'screens/student/internship_details_screen.dart';
import 'screens/student/notifications_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/student_management_screen.dart';
import 'screens/admin/student_detail_screen.dart';
import 'screens/admin/skill_search_screen.dart';
import 'screens/admin/certificate_verification_screen.dart';
import 'screens/admin/add_students_screen.dart';
import 'screens/admin/assign_internship_screen.dart';
import 'screens/admin/reports_screen.dart';
import 'models/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InternInfo - Internship Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        
        // Student Routes
        '/student/dashboard': (context) => const StudentDashboard(),
        '/student/profile': (context) => const StudentProfileScreen(),
        '/student/skills': (context) => const StudentSkillsScreen(),
        '/student/resume': (context) => const ResumeUploadScreen(),
        '/student/certificates': (context) => const CertificatesScreen(),
        '/student/internship': (context) => const InternshipDetailsScreen(),
        '/student/notifications': (context) => const NotificationsScreen(),
        
        // Admin Routes
        '/admin/dashboard': (context) => const AdminDashboard(),
        '/admin/students': (context) => const StudentManagementScreen(),
        '/admin/skill-search': (context) => const SkillBasedSearchScreen(),
        '/admin/verify-certificates': (context) => const CertificateVerificationScreen(),
        '/admin/assign-internship': (context) => const AssignInternshipScreen(),
        '/admin/add-students': (context) => const AddStudentsScreen(),
        '/admin/reports': (context) => const ReportsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin/student-detail') {
          final student = settings.arguments as UserProfile;
          return MaterialPageRoute(
            builder: (context) => StudentDetailScreen(student: student),
          );
        }
        return null;
      },
    );
  }
}
