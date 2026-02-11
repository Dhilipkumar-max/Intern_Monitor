import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../models/certificate.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';

class CertificateVerificationScreen extends StatefulWidget {
  const CertificateVerificationScreen({super.key});

  @override
  State<CertificateVerificationScreen> createState() => _CertificateVerificationScreenState();
}

class _CertificateVerificationScreenState extends State<CertificateVerificationScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  UserProfile? _adminProfile;
  List<Certificate> _pendingCertificates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userId = _authService.currentUserId;
    if (userId != null) {
      _adminProfile = await _authService.getUserProfile(userId);
      _pendingCertificates = await _adminService.getPendingCertificates();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _verifyCertificate(String id, bool approved) async {
    final adminId = _authService.currentUserId;
    if (adminId == null) return;

    bool success;
    if (approved) {
      success = await _adminService.verifyCertificate(id, adminId);
    } else {
      success = await _adminService.rejectCertificate(id, adminId, 'Certificate review failed');
    }

    final statusText = approved ? 'verified' : 'rejected';

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Certificate $statusText successfully'),
          backgroundColor: approved ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
      _loadData();
    }
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
            currentRoute: '/admin/verify-certificates',
            items: [
              SidebarItem(icon: Icons.dashboard, label: 'Dashboard', route: '/admin/dashboard'),
              SidebarItem(icon: Icons.people, label: 'Students', route: '/admin/students'),
              SidebarItem(icon: Icons.search, label: 'Skill Search', route: '/admin/skill-search'),
              SidebarItem(icon: Icons.assignment, label: 'Assign Internship', route: '/admin/assign-internship'),
              SidebarItem(icon: Icons.verified, label: 'Verify Certificates', route: '/admin/verify-certificates'),
              SidebarItem(icon: Icons.person_add, label: 'Add Students', route: '/admin/add-students'),
              SidebarItem(icon: Icons.analytics, label: 'Reports', route: '/admin/reports'),
            ],
            onLogout: _handleLogout,
            userName: _adminProfile?.name ?? 'Admin',
            userEmail: _adminProfile?.email ?? '',
          ),
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Certificate Verification',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Review and approve academic or professional certificates submitted by students.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 32),

                          Expanded(
                            child: _pendingCertificates.isEmpty
                                ? const Center(child: Text('No pending certificates for verification.'))
                                : ListView.builder(
                                    itemCount: _pendingCertificates.length,
                                    itemBuilder: (context, index) {
                                      final cert = _pendingCertificates[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Icon(Icons.workspace_premium, color: AppTheme.primaryColor),
                                              ),
                                              const SizedBox(width: 24),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      cert.certificateType,
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Uploaded: ${cert.createdAt.toString().split(' ')[0]}',
                                                      style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 32),
                                              OutlinedButton.icon(
                                                onPressed: () => _viewFile(cert.fileUrl),
                                                icon: const Icon(Icons.visibility),
                                                label: const Text('View File'),
                                              ),
                                              const SizedBox(width: 16),
                                              ElevatedButton.icon(
                                                onPressed: () => _verifyCertificate(cert.id, true),
                                                icon: const Icon(Icons.check),
                                                label: const Text('Approve'),
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                                              ),
                                              const SizedBox(width: 16),
                                              ElevatedButton.icon(
                                                onPressed: () => _verifyCertificate(cert.id, false),
                                                icon: const Icon(Icons.close),
                                                label: const Text('Reject'),
                                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
