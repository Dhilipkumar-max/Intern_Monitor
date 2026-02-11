import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../models/skill.dart';
import '../../models/certificate.dart';
import '../../models/internship.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';

class StudentDetailScreen extends StatefulWidget {
  final UserProfile student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _adminProfile;
  List<Skill> _skills = [];
  List<Certificate> _certificates = [];
  List<Internship> _internships = [];
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
      _skills = await _studentService.getSkills(widget.student.id);
      _certificates = await _studentService.getCertificates(widget.student.id);
      _internships = await _studentService.getInternships(widget.student.id);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _viewFile(String? urlString) async {
    if (urlString == null) return;
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
            currentRoute: '/admin/students',
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
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Student Details',
                                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Personal Info & Resume
                              Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    _buildInfoCard(),
                                    const SizedBox(height: 24),
                                    _buildResumeCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Skills & Certificates
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildSkillsCard(),
                                    const SizedBox(height: 24),
                                    _buildCertificatesCard(),
                                    const SizedBox(height: 24),
                                    _buildInternshipCard(),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                widget.student.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.student.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(widget.student.email, style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildDetailRow('Reg. No', widget.student.registerNumber ?? 'N/A'),
            _buildDetailRow('Department', widget.student.department ?? 'N/A'),
            _buildDetailRow('Year', widget.student.year?.toString() ?? 'N/A'),
            _buildDetailRow('Phone', widget.student.phoneNumber ?? 'N/A'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showSendMessageDialog,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSendMessageDialog() async {
    final titleController = TextEditingController(text: 'Message from Admin');
    final messageController = TextEditingController();
    final _adminService = AdminService();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.message_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text('Message ${widget.student.name.split(' ')[0]}'),
          ],
        ),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Your Message',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a message')),
                );
                return;
              }
              
              final success = await _adminService.sendNotification(
                studentId: widget.student.id,
                title: titleController.text,
                message: messageController.text,
              );

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification sent to student'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildResumeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (widget.student.resumeUrl != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _viewFile(widget.student.resumeUrl),
                  icon: const Icon(Icons.description),
                  label: const Text('View Resume PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.infoColor),
                ),
              )
            else
              const Text('No resume uploaded.', style: TextStyle(fontStyle: FontStyle.italic, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_skills.isEmpty)
              const Text('No skills listed.')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills.map((skill) => Chip(
                  label: Text('${skill.skillName} (${skill.skillLevel})'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Certificates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_certificates.isEmpty)
              const Text('No certificates uploaded.')
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
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20),
                          onPressed: () => _viewFile(cert.fileUrl),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInternshipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Internship History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_internships.isEmpty)
              const Text('No internships assigned yet.')
            else
              ..._internships.map((internship) => Column(
                children: [
                  ListTile(
                    title: Text(internship.title),
                    subtitle: Text(internship.company),
                    trailing: StatusBadge(status: internship.status),
                  ),
                  const Divider(),
                ],
              )),
          ],
        ),
      ),
    );
  }
}
