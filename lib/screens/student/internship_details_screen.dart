import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../models/internship.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';

class InternshipDetailsScreen extends StatefulWidget {
  const InternshipDetailsScreen({super.key});

  @override
  State<InternshipDetailsScreen> createState() => _InternshipDetailsScreenState();
}

class _InternshipDetailsScreenState extends State<InternshipDetailsScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _profile;
  List<Internship>? _internships;
  bool _isLoading = true;
  bool _isUploading = false;

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
      final internships = await _studentService.getInternships(userId);
      setState(() {
        _profile = profile;
        _internships = internships;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteInternship(Internship internship) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Internship'),
        content: Text('Are you sure you want to delete "${internship.title}" at "${internship.company}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _studentService.deleteInternship(internship.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Internship deleted' : 'Failed to delete internship'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
        if (success) _loadData();
      }
    }
  }

  Future<void> _uploadCompletionCert(Internship internship) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
      withData: true,
    );

    if (result != null) {
      setState(() => _isUploading = true);
      final userId = await _authService.currentUserId;
      if (userId == null) return;
      final file = result.files.first;
      
      final url = await _studentService.uploadCertificateFile(userId, file.name, file.bytes!);
      
      if (url != null) {
        final success = await _studentService.uploadCompletionCertificate(internship.id, url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Completion certificate uploaded successfully'), backgroundColor: AppTheme.successColor),
          );
          await _loadData();
        }
      }
      setState(() => _isUploading = false);
    }
  }

  Future<void> _showInternshipDialog({Internship? internship}) async {
    final isEditing = internship != null;
    final titleController = TextEditingController(text: internship?.title);
    final companyController = TextEditingController(text: internship?.company);
    final roleController = TextEditingController(text: internship?.role);
    final durationController = TextEditingController(text: internship?.duration);
    String? certUrl = internship?.completionCertificateUrl;
    bool isUploadingCert = false;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Professional History' : 'New Internship Entry',
                    style: GoogleFonts.manrope(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maintain your academic and professional record accuracy.',
                    style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _buildDialogField('Internship Title', 'e.g. Frontend Engineering Intern', titleController),
                  const SizedBox(height: 20),
                  _buildDialogField('Company/Organization', 'e.g. Google India', companyController),
                  const SizedBox(height: 20),
                  _buildDialogField('Role/Responsibilities', 'Brief description of your work', roleController, maxLines: 3),
                  const SizedBox(height: 20),
                  _buildDialogField('Tenure/Duration', 'e.g. May 2023 - July 2023', durationController),
                  const SizedBox(height: 32),
                  if (certUrl == null)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: isUploadingCert ? null : () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                            withData: true,
                          );
                          if (result != null) {
                            setDialogState(() => isUploadingCert = true);
                            final file = result.files.first;
                            final userId = await _authService.currentUserId;
                            if (userId == null) return;
                            final url = await _studentService.uploadCertificateFile(
                              userId, 
                              file.name, 
                              file.bytes!
                            );
                            setDialogState(() {
                              certUrl = url;
                              isUploadingCert = false;
                            });
                          }
                        },
                        icon: isUploadingCert 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Icon(Icons.upload_file_rounded),
                        label: Text(isUploadingCert ? 'UPLOADING...' : 'ATTACH COMPLETION CERTIFICATE (OPTIONAL)'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.all(20),
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Certificate Attached',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => setDialogState(() => certUrl = null),
                            tooltip: 'Remove',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: isSaving ? null : () async {
                          if (titleController.text.isEmpty || companyController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Title and Company are required')),
                            );
                            return;
                          }
                          
                          setDialogState(() => isSaving = true);
                          try {
                            bool success;
                            if (isEditing) {
                              success = await _studentService.updateInternship(
                                internshipId: internship!.id,
                                title: titleController.text.trim(),
                                company: companyController.text.trim(),
                                role: roleController.text.trim(),
                                duration: durationController.text.trim(),
                                certificateUrl: certUrl,
                              );
                            } else {
                              final userId = await _authService.currentUserId;
                              if (userId == null) return;
                              success = await _studentService.addInternship(
                                userId: userId,
                                title: titleController.text.trim(),
                                company: companyController.text.trim(),
                                role: roleController.text.trim(),
                                duration: durationController.text.trim(),
                                certificateUrl: certUrl,
                              );
                            }

                            if (success) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isEditing ? 'Record updated' : 'Experience added'), 
                                    backgroundColor: AppTheme.primaryColor
                                  ),
                                );
                                _loadData();
                              }
                            }
                          } finally {
                            if (mounted) setDialogState(() => isSaving = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isSaving 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEditing ? 'Update Experience' : 'Save Experience', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary.withOpacity(0.5), fontSize: 14),
            filled: true,
            fillColor: AppTheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
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
              currentRoute: '/student/internship',
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
                        _buildHeader(isMobile),
                        const SizedBox(height: 48),
                        if (_internships == null || _internships!.isEmpty)
                          _buildEmptyState()
                        else
                          ..._internships!.map((internship) => _buildInternshipCard(internship)).toList(),
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
        ? Text('Internships', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppTheme.primaryColor))
        : null,
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIELD EXPERIENCE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Professional History',
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (!isMobile)
          ElevatedButton.icon(
            onPressed: () => _showInternshipDialog(),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text('New Experience', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Icon(Icons.business_center_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            'No Internships Recorded',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep your professional record updated by adding your placement details.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => _showInternshipDialog(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Your First Internship'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInternshipCard(Internship internship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.business_rounded, color: AppTheme.primaryColor, size: 28),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      internship.title.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Text(
                      internship.company,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      internship.duration ?? 'Duration Not Specified',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadge(status: internship.status),
                  const SizedBox(height: 8),
                  _buildActionMenu(internship),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 32),
          Text(
            'ROLE & RESPONSIBILITIES',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            internship.role ?? 'No description provided.',
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: AppTheme.textPrimary.withOpacity(0.8),
            ),
          ),
          if (internship.requiredSkills != null && internship.requiredSkills!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: internship.requiredSkills!
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 32),
          _buildCertificateFooter(internship),
        ],
      ),
    );
  }

  Widget _buildCertificateFooter(Internship internship) {
    final bool hasCert = internship.completionCertificateUrl != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasCert ? AppTheme.primaryColor.withOpacity(0.03) : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: hasCert ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.borderColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasCert ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasCert ? Icons.verified_rounded : Icons.pending_actions_rounded,
              color: hasCert ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCert ? 'COMPLETION CERTIFICATE VERIFIED' : 'PENDING COMPLETION',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: hasCert ? AppTheme.primaryColor : AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  hasCert ? 'Official credential attached to record' : 'Upload your cert when tenure completes',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (hasCert)
            TextButton.icon(
              onPressed: () => launchUrl(Uri.parse(internship.completionCertificateUrl!)),
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: Text('View', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            )
          else
            TextButton.icon(
              onPressed: () => _uploadCompletionCert(internship),
              icon: const Icon(Icons.file_upload_rounded, size: 18),
              label: Text('Upload', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(Internship internship) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _showInternshipDialog(internship: internship)),
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, size: 18),
              const SizedBox(width: 12),
              Text('Edit Details', style: GoogleFonts.inter()),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => Future.delayed(Duration.zero, () => _deleteInternship(internship)),
          child: Row(
            children: [
              const Icon(Icons.delete_rounded, size: 18, color: AppTheme.errorColor),
              const SizedBox(width: 12),
              Text('Remove', style: GoogleFonts.inter(color: AppTheme.errorColor)),
            ],
          ),
        ),
      ],
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
