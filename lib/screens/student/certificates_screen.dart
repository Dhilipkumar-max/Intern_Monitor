import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../models/certificate.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';

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
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      final certificates = await _studentService.getCertificates(userId);
      setState(() {
        _profile = profile;
        _certificates = certificates;
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
    if (_selectedFile == null || _selectedFile!.bytes == null || _typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter type and select a file')),
      );
      return;
    }

    setState(() => _isUploading = true);

    final userId = _authService.currentUserId;
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
              content: Text(success ? 'Certificate submitted for verification' : 'Failed to save certificate data'),
              backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
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
        content: Text('Are you sure you want to delete "${cert.certificateType}"?'),
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
      final success = await _studentService.deleteCertificate(cert.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Certificate deleted' : 'Failed to delete certificate'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
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
              onPressed: isSaving ? null : () async {
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
                      content: Text(success ? 'Certificate updated' : 'Failed to update certificate'),
                      backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
                    ),
                  );
                  if (success) _loadData();
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewFile(String urlString) async {
    final url = Uri.parse(urlString);
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
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentRoute: '/student/certificates',
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
                            'My Certificates',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Manage your professional and academic certificates',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Add New Section
                                  Expanded(
                                    flex: 2,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Upload New Certificate',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            TextField(
                                              controller: _typeController,
                                              decoration: const InputDecoration(
                                                labelText: 'Certificate Type / Name',
                                                hintText: 'e.g., AWS Cloud Practitioner, Coursera Python',
                                                prefixIcon: Icon(Icons.label_outline),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            InkWell(
                                              onTap: _pickFile,
                                              child: Container(
                                                padding: const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: AppTheme.borderColor),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.attach_file, color: AppTheme.textSecondary),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        _selectedFile?.name ?? 'Select Certificate File',
                                                        style: TextStyle(
                                                          color: _selectedFile == null 
                                                              ? AppTheme.textSecondary 
                                                              : AppTheme.textPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: _isUploading ? null : _uploadCertificate,
                                                icon: _isUploading
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                      )
                                                    : const Icon(Icons.cloud_upload),
                                                label: const Text('Submit for Verification'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 32),
                                  // List Section
                                  Expanded(
                                    flex: 3,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Verification History',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            if (_certificates.isEmpty)
                                              const Center(
                                                child: Padding(
                                                  padding: EdgeInsets.all(32),
                                                  child: Text('No certificates uploaded yet'),
                                                ),
                                              )
                                            else
                                              ListView.separated(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: _certificates.length,
                                                separatorBuilder: (context, index) => const Divider(),
                                                itemBuilder: (context, index) {
                                                  final cert = _certificates[index];
                                                  return ListTile(
                                                    title: Text(cert.certificateType),
                                                    subtitle: Text(cert.fileName),
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        StatusBadge(status: cert.verificationStatus),
                                                        const SizedBox(width: 8),
                                                        IconButton(
                                                          icon: const Icon(Icons.open_in_new, size: 20),
                                                          onPressed: () => _viewFile(cert.fileUrl),
                                                          tooltip: 'View File',
                                                        ),
                                                        PopupMenuButton(
                                                          icon: const Icon(Icons.more_vert, size: 20),
                                                          itemBuilder: (context) => [
                                                            PopupMenuItem(
                                                              onTap: () => Future.delayed(Duration.zero, () => _editCertificate(cert)),
                                                              child: const Row(
                                                                children: [
                                                                  Icon(Icons.edit, size: 18),
                                                                  SizedBox(width: 8),
                                                                  Text('Edit'),
                                                                ],
                                                              ),
                                                            ),
                                                            PopupMenuItem(
                                                              onTap: () => Future.delayed(Duration.zero, () => _deleteCertificate(cert)),
                                                              child: const Row(
                                                                children: [
                                                                  Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                                                                  SizedBox(width: 8),
                                                                  Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
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

  @override
  void dispose() {
    _typeController.dispose();
    super.dispose();
  }
}
