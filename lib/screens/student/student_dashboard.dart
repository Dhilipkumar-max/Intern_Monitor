import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/status_badge.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _profile;
  Map<String, dynamic> _stats = {};
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
      final profile = await _authService.getUserProfile(userId);
      final stats = await _studentService.getDashboardStats(userId);

      setState(() {
        _profile = profile;
        _stats = stats;
        _isLoading = false;
      });
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AppSidebar(
            currentRoute: '/student/dashboard',
            items: [
              SidebarItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                route: '/student/dashboard',
              ),
              SidebarItem(
                icon: Icons.person,
                label: 'Profile',
                route: '/student/profile',
              ),
              SidebarItem(
                icon: Icons.code,
                label: 'Skills',
                route: '/student/skills',
              ),
              SidebarItem(
                icon: Icons.description,
                label: 'Resume',
                route: '/student/resume',
              ),
              SidebarItem(
                icon: Icons.workspace_premium,
                label: 'Certificates',
                route: '/student/certificates',
              ),
              SidebarItem(
                icon: Icons.business_center,
                label: 'Internship',
                route: '/student/internship',
              ),
              SidebarItem(
                icon: Icons.notifications,
                label: 'Notifications',
                route: '/student/notifications',
              ),
            ],
            onLogout: _handleLogout,
            userName: _profile?.name ?? 'Student',
            userEmail: _profile?.email ?? '',
          ),

          // Main Content
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${_profile?.name ?? 'Student'}!',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Here\'s your internship overview',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _loadData,
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Profile Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                _profile?.name[0].toUpperCase() ?? 'S',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profile?.name ?? 'Student Name',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildInfoChip(
                                        Icons.badge,
                                        _profile?.registerNumber ?? 'N/A',
                                      ),
                                      const SizedBox(width: 12),
                                      _buildInfoChip(
                                        Icons.school,
                                        _profile?.department ?? 'N/A',
                                      ),
                                      const SizedBox(width: 12),
                                      _buildInfoChip(
                                        Icons.calendar_today,
                                        'Year ${_profile?.year ?? 'N/A'}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/student/profile');
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Stats Cards
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        DashboardCard(
                          title: 'Profile Completion',
                          value: '${_profile?.profileCompletion ?? 0}%',
                          icon: Icons.person_outline,
                          color: AppTheme.primaryColor,
                        ),
                        DashboardCard(
                          title: 'Skills Added',
                          value: '${_stats['skillsCount'] ?? 0}',
                          icon: Icons.code,
                          color: AppTheme.secondaryColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/student/skills');
                          },
                        ),
                        DashboardCard(
                          title: 'Certificates',
                          value: '${_stats['certificatesCount'] ?? 0}',
                          icon: Icons.workspace_premium,
                          color: AppTheme.accentColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/student/certificates');
                          },
                        ),
                        DashboardCard(
                          title: 'Notifications',
                          value: '${_stats['unreadNotifications'] ?? 0}',
                          icon: Icons.notifications_outlined,
                          color: AppTheme.warningColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/student/notifications');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Internship Status
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Internship Status',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                StatusBadge(
                                  status: _stats['internshipStatus'] ?? 'Not Assigned',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),
                            if (_stats['internshipStatus'] == 'Not Assigned')
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.business_center_outlined,
                                      size: 64,
                                      color: AppTheme.textSecondary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No internship assigned yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Complete your profile and add skills to get matched with internships',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/student/internship');
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('View Internship Details'),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildQuickAction(
                          icon: Icons.code,
                          label: 'Add Skills',
                          onTap: () {
                            Navigator.pushNamed(context, '/student/skills');
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.upload_file,
                          label: 'Upload Resume',
                          onTap: () {
                            Navigator.pushNamed(context, '/student/resume');
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.workspace_premium,
                          label: 'Upload Certificate',
                          onTap: () {
                            Navigator.pushNamed(context, '/student/certificates');
                          },
                        ),
                        _buildQuickAction(
                          icon: Icons.person,
                          label: 'Update Profile',
                          onTap: () {
                            Navigator.pushNamed(context, '/student/profile');
                          },
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
