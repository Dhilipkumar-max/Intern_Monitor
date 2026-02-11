import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';

class ResumeUploadScreen extends StatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  State<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends State<ResumeUploadScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _profile;
  bool _isLoading = true;
  bool _isUploading = false;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadResume() async {
    if (_selectedFile == null || _selectedFile!.bytes == null) return;

    setState(() => _isUploading = true);

    final userId = _authService.currentUserId;
    if (userId != null) {
      final fileName = _selectedFile!.name;
      final fileBytes = _selectedFile!.bytes!;
      
      final url = await _studentService.uploadResume(userId, fileName, fileBytes);

      if (url != null) {
        // Update profile with resume URL
        final success = await _authService.updateProfile(userId, {
          'resume_url': url,
          'profile_completion': (_profile?.profileCompletion ?? 0) < 80 ? 80 : _profile?.profileCompletion,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Resume uploaded successfully' : 'Resume uploaded but profile update failed'),
              backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
            ),
          );
          _selectedFile = null;
          await _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload resume to storage'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
    setState(() => _isUploading = false);
  }

  Future<void> _viewResume() async {
    if (_profile?.resumeUrl != null) {
      final url = Uri.parse(_profile!.resumeUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open resume URL')),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentRoute: '/student/resume',
            items: [
              SidebarItem(icon: Icons.dashboard, label: 'Dashboard', route: '/student/dashboard'),
              SidebarItem(icon: Icons.person, label: 'Profile', route: '/student/profile'),
              SidebarItem(icon: Icons.code, label: 'Skills', route: '/student/skills'),
              SidebarItem(icon: Icons.description, label: 'Resume', route: '/student/resume'),
              SidebarItem(icon: Icons.workspace_premium, label: 'Certificates', route: '/student/certificates'),
              SidebarItem(icon: Icons.business_center, label: 'Internship', route: '/student/internship'),
              SidebarItem(icon: Icons.notifications, label: 'Notifications', route: '/student/notifications'),
            ],
            onLogout: _handleLogout,
            userName: _profile?.name ?? 'Student',
            userEmail: _profile?.email ?? '',
          ),
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resume Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload and maintain your standard professional resume (PDF)',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      // Icon
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.picture_as_pdf,
                                          size: 48,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      if (_profile?.resumeUrl != null) ...[
                                        const Text(
                                          'Resume Uploaded',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Your current resume is available for admins to review.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          onPressed: _viewResume,
                                          icon: const Icon(Icons.visibility),
                                          label: const Text('View Current Resume'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.infoColor,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                        const Divider(),
                                        const SizedBox(height: 32),
                                        const Text(
                                          'Update Resume',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ] else ...[
                                        const Text(
                                          'No Resume Uploaded',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Please upload your resume in PDF format to be considered for internships.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 32),
                                      ],

                                      // File Picker Area
                                      InkWell(
                                        onTap: _isUploading ? null : _pickFile,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(32),
                                          decoration: BoxDecoration(
                                            color: AppTheme.backgroundColor,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppTheme.borderColor,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              const Icon(
                                                Icons.cloud_upload_outlined,
                                                size: 32,
                                                color: AppTheme.textSecondary,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                _selectedFile?.name ?? 'Click to select PDF file',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Maximum size: 5MB',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      if (_selectedFile != null) ...[
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _isUploading ? null : _uploadResume,
                                            icon: _isUploading
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : const Icon(Icons.upload),
                                            label: Text(_isUploading ? 'Uploading...' : 'Confirm Upload'),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
