import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
    final userId = _authService.currentUserId;
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
      final userId = _authService.currentUserId!;
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
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Internship' : 'Add Internship Experience'),
          content: Container(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Internship Title',
                      hintText: 'e.g. Flutter Developer Intern',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: companyController,
                    decoration: const InputDecoration(
                      labelText: 'Company Name',
                      hintText: 'e.g. Tech Solutions',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: roleController,
                    decoration: const InputDecoration(
                      labelText: 'Role/Responsibilities',
                      hintText: 'e.g. Developing mobile UI with Flutter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      hintText: 'e.g. June 2023 - August 2023',
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (certUrl == null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: isUploadingCert ? null : () async {
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                            withData: true,
                          );
                          if (result != null) {
                            setDialogState(() => isUploadingCert = true);
                            final file = result.files.first;
                            final url = await _studentService.uploadCertificateFile(
                              _authService.currentUserId!, 
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
                          : const Icon(Icons.upload_file),
                        label: Text(isUploadingCert ? 'Uploading...' : 'Upload Completion Certificate'),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.successColor),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Certificate Attached', style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold))),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => setDialogState(() => certUrl = null),
                            tooltip: 'Replace Certificate',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (titleController.text.isEmpty || companyController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in required fields')),
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
                    success = await _studentService.addInternship(
                      userId: _authService.currentUserId!,
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
                          content: Text(isEditing ? 'Internship updated successfully' : 'Internship added successfully'), 
                          backgroundColor: AppTheme.successColor
                        ),
                      );
                      _loadData();
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save internship. Please try again.'), backgroundColor: AppTheme.errorColor),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorColor),
                    );
                  }
                } finally {
                  if (mounted) {
                    setDialogState(() => isSaving = false);
                  }
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
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
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentRoute: '/student/internship',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Internships',
                                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Manage your internship experiences and certificates',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _showInternshipDialog(),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Internship'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          if (_internships == null || _internships!.isEmpty)
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(48),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.borderColor),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.business_center_outlined, size: 80, color: AppTheme.textSecondary.withOpacity(0.3)),
                                    const SizedBox(height: 24),
                                    const Text(
                                      'No Internships Found',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Click the "Add Internship" button to record your experience.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _internships!.length,
                              itemBuilder: (context, index) {
                                final internship = _internships![index];
                                return _buildInternshipCard(internship);
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

  Widget _buildInternshipCard(Internship internship) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      constraints: const BoxConstraints(maxWidth: 900),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          internship.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.business, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              internship.company,
                              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      StatusBadge(status: internship.status),
                      const SizedBox(width: 8),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () => Future.delayed(Duration.zero, () => _showInternshipDialog(internship: internship)),
                            child: const Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () => Future.delayed(Duration.zero, () => _deleteInternship(internship)),
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
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildInfoItem(Icons.work_outline, 'Role', internship.role ?? 'N/A')),
                  Expanded(child: _buildInfoItem(Icons.timer_outlined, 'Duration', internship.duration ?? 'N/A')),
                  Expanded(child: _buildInfoItem(Icons.calendar_today_outlined, 'Added On', internship.createdAt.toString().split(' ')[0])),
                ],
              ),
              if (internship.requiredSkills != null && internship.requiredSkills!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text('Associated Skills', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: internship.requiredSkills!
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppTheme.primaryColor.withOpacity(0.05),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),
              if (internship.completionCertificateUrl == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : () => _uploadCompletionCert(internship),
                    icon: _isUploading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload_file),
                    label: const Text('Upload Completion Certificate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.successColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, color: AppTheme.successColor, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Internship Completed', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successColor)),
                          Text('Certificate verified and attached', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => launchUrl(Uri.parse(internship.completionCertificateUrl!)),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Certificate'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
      ],
    );
  }
}
