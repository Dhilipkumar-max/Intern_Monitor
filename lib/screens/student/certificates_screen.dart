import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../models/certificate.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';
import '../../config/api_config.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _profile;
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  bool _isUploading = false;

  final _typeController = TextEditingController();
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
      final certificatesData = await _studentService.getCertificates(userId);
      setState(() {
        _profile = profile;
        _certificates = certificatesData;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadCertificate() async {
    if (_selectedFile == null ||
        _selectedFile!.bytes == null ||
        _typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter type and select a file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final userId = await _authService.currentUserId;
    if (userId != null) {
      final fileUrl = await _studentService.uploadCertificateFile(
        userId,
        _selectedFile!.name,
        _selectedFile!.bytes!,
      );

      if (fileUrl != null) {
        final success = await _studentService.uploadCertificate(
          userId: userId,
          certificateType: _typeController.text.trim(),
          fileUrl: fileUrl,
          fileName: _selectedFile!.name,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Certificate submitted for verification'
                    : 'Failed to save certificate data',
              ),
              backgroundColor: success
                  ? AppTheme.successColor
                  : AppTheme.errorColor,
            ),
          );
          if (success) {
            _typeController.clear();
            _selectedFile = null;
            await _loadData();
          }
        }
      }
    }
    setState(() => _isUploading = false);
  }

  Future<void> _deleteCertificate(Certificate cert) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text(
          'Are you sure you want to delete "${cert.certificateType}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _studentService.deleteCertificate(cert.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Certificate deleted' : 'Failed to delete certificate',
            ),
            backgroundColor: success
                ? AppTheme.successColor
                : AppTheme.errorColor,
          ),
        );
        if (success) _loadData();
      }
    }
  }

  Future<void> _editCertificate(Certificate cert) async {
    final controller = TextEditingController(text: cert.certificateType);
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Certificate'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Certificate Type / Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (controller.text.isEmpty) return;
                      setDialogState(() => isSaving = true);
                      final success = await _studentService.updateCertificate(
                        certificateId: cert.id,
                        certificateType: controller.text.trim(),
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Certificate updated'
                                  : 'Failed to update certificate',
                            ),
                            backgroundColor: success
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                        );
                        if (success) _loadData();
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewFile(String urlString) async {
    final fullUrl = ApiConfig.getFileUrl(urlString);
    final url = Uri.parse(fullUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
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

    final isMobile = MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            AppSidebar(
              currentRoute: '/student/certificates',
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
                        if (isMobile) ...[
                          _buildUploadForm(),
                          const SizedBox(height: 32),
                          _buildHistorySection(),
                        ] else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: _buildUploadForm()),
                              const SizedBox(width: 32),
                              Expanded(flex: 3, child: _buildHistorySection()),
                            ],
                          ),
                        ],
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
        ? Text('Certificates', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppTheme.primaryColor))
        : null,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CREDENTIALS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Certificate Verification',
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'UPLOAD NEW',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Certificate Title',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _typeController,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'e.g. Google Cloud Professional',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppTheme.borderColor.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Document File',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                   Icon(
                    _selectedFile != null ? Icons.check_circle_rounded : Icons.add_rounded,
                    color: _selectedFile != null ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFile?.name ?? 'Select PDF or Image',
                      style: GoogleFonts.inter(
                        color: _selectedFile != null ? AppTheme.textPrimary : AppTheme.textSecondary,
                        fontWeight: _selectedFile != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _uploadCertificate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: _isUploading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Submit for Verification', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 24),
          child: Text(
            'VERIFICATION HISTORY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
        ),
        if (_certificates.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow.withOpacity(0.5),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                Icon(Icons.history_edu_rounded, size: 48, color: AppTheme.textSecondary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No records found',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        else
          ..._certificates.map((cert) => _buildCertificateListItem(cert)).toList(),
      ],
    );
  }

  Widget _buildCertificateListItem(Certificate cert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              color: AppTheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.certificateType,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Uploaded on ${_formatDate(cert.createdAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          StatusBadge(status: cert.verificationStatus),
          const SizedBox(width: 12),
          if (cert.adminRemark != null && cert.adminRemark!.isNotEmpty)
            Tooltip(
              message: cert.adminRemark!,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline_rounded, size: 16, color: AppTheme.warningColor),
              ),
            ),
          const SizedBox(width: 12),
          _buildActionMenu(cert),
        ],
      ),
    );
  }

  Widget _buildActionMenu(Certificate cert) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => _viewFile(cert.fileUrl),
          child: Row(
            children: [
              const Icon(Icons.visibility_rounded, size: 20),
              const SizedBox(width: 12),
              Text('View Document', style: GoogleFonts.inter()),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _editCertificate(cert)),
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, size: 20, color: AppTheme.infoColor),
              const SizedBox(width: 12),
              Text('Edit Title', style: GoogleFonts.inter()),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _deleteCertificate(cert)),
          child: Row(
            children: [
              const Icon(Icons.delete_rounded, size: 20, color: AppTheme.errorColor),
              const SizedBox(width: 12),
              Text('Delete', style: GoogleFonts.inter(color: AppTheme.errorColor)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
          _buildNavItem(Icons.workspace_premium_rounded, 'Certs', true, route: '/student/certificates'),
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
  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }
}
