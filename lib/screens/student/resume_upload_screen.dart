import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';
import '../../config/api_config.dart';

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
    final userId = await _authService.currentUserId;
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

    final userId = await _authService.currentUserId;
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
      final fullUrl = ApiConfig.getFileUrl(_profile!.resumeUrl!);
      final url = Uri.parse(fullUrl);
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            AppSidebar(
              currentRoute: '/student/resume',
              items: _buildSidebarItems(),
              onLogout: _handleLogout,
              userName: _profile?.name ?? 'Student',
              userEmail: _profile?.email ?? '',
            ),

          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: CustomScrollView(
                slivers: [
                  _buildTopAppBar(isMobile),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 48,
                      vertical: 32,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildUploadSection(isMobile),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNavBar() : null,
    );
  }

  List<SidebarItem> _buildSidebarItems() {
    return [
      SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/student/dashboard'),
      SidebarItem(icon: Icons.person_rounded, label: 'Profile', route: '/student/profile'),
      SidebarItem(icon: Icons.code_rounded, label: 'Skills', route: '/student/skills'),
      SidebarItem(icon: Icons.description_rounded, label: 'Resume', route: '/student/resume'),
      SidebarItem(icon: Icons.workspace_premium_rounded, label: 'Certificates', route: '/student/certificates'),
      SidebarItem(icon: Icons.business_center_rounded, label: 'Internship', route: '/student/internship'),
      SidebarItem(icon: Icons.rocket_launch_rounded, label: 'Projects', route: '/student/projects'),
      SidebarItem(icon: Icons.notifications_rounded, label: 'Notifications', route: '/student/notifications'),
    ];
  }

  Widget _buildTopAppBar(bool isMobile) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white.withOpacity(0.7),
      surfaceTintColor: Colors.transparent,
      leading: isMobile 
        ? IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor),
            onPressed: () {},
          )
        : null,
      title: isMobile 
        ? Text('Resume', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppTheme.primaryColor))
        : null,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CAREER ASSETS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Resume Management',
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(bool isMobile) {
    final bool hasResume = _profile?.resumeUrl != null;

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.description_rounded, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasResume ? 'CURRICULUM VITAE UPLOADED' : 'RESUME REQUIRED',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: hasResume ? AppTheme.primaryColor : AppTheme.secondaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      hasResume ? 'Your profile is ready for applications' : 'Upload your PDF resume to continue',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          
          if (hasResume) ...[
             _buildStatusCard(),
             const SizedBox(height: 48),
             Text(
              'UPDATE YOUR RESUME',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildDropZone(),
          
          if (_selectedFile != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isUploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Confirm and Upload', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8), // Light red for PDF icon
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFE02424), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current_Resume.pdf',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Standard Academic Format',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _viewResume,
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: Text('View', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    return InkWell(
      onTap: _isUploading ? null : _pickFile,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.8),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHighest.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _selectedFile != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined,
                size: 32,
                color: _selectedFile != null ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFile?.name ?? 'Click to Upload PDF',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFile != null 
                ? '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB • Ready to upload'
                : 'Maximum file size: 5 MB',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Home', false, route: '/student/dashboard'),
          _buildNavItem(Icons.rocket_launch_rounded, 'Projects', false, route: '/student/projects'),
          _buildNavItem(Icons.workspace_premium_rounded, 'Certs', false, route: '/student/certificates'),
          _buildNavItem(Icons.person_rounded, 'Profile', false, route: '/student/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {required String route}) {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
