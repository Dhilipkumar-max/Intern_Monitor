import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/dashboard_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

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

    final userId = await _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      final stats = await _adminService.getDashboardStats();

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
            currentRoute: '/admin/dashboard',
            items: [
              SidebarItem(
                icon: Icons.dashboard,
                label: 'Dashboard',
                route: '/admin/dashboard',
              ),
              SidebarItem(
                icon: Icons.people,
                label: 'Students',
                route: '/admin/students',
              ),
              SidebarItem(
                icon: Icons.search,
                label: 'Skill Search',
                route: '/admin/skill-search',
              ),
              SidebarItem(
                icon: Icons.assignment,
                label: 'Assign Internship',
                route: '/admin/assign-internship',
              ),
              SidebarItem(
                icon: Icons.verified,
                label: 'Verify Certificates',
                route: '/admin/verify-certificates',
              ),
              SidebarItem(
                icon: Icons.person_add,
                label: 'Add Students',
                route: '/admin/add-students',
              ),
              SidebarItem(
                icon: Icons.analytics,
                label: 'Reports',
                route: '/admin/reports',
              ),
            ],
            onLogout: _handleLogout,
            userName: _profile?.name ?? 'Admin',
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
                              'Admin Dashboard',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Internship Management Overview',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin/add-students');
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Add Student'),
                            ),
                          ],
                        ),
                      ],
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
                          title: 'Total Students',
                          value: '${_stats['totalStudents'] ?? 0}',
                          icon: Icons.people,
                          color: AppTheme.primaryColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/admin/students');
                          },
                        ),
                        DashboardCard(
                          title: 'Without Internships',
                          value: '${_stats['studentsWithoutInternships'] ?? 0}',
                          icon: Icons.warning_amber,
                          color: AppTheme.warningColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/admin/students');
                          },
                        ),
                        DashboardCard(
                          title: 'Pending Certificates',
                          value: '${_stats['pendingCertificates'] ?? 0}',
                          icon: Icons.pending_actions,
                          color: AppTheme.infoColor,
                          onTap: () {
                            Navigator.pushNamed(context, '/admin/verify-certificates');
                          },
                        ),
                        DashboardCard(
                          title: 'Completed Internships',
                          value: '${_stats['completedInternships'] ?? 0}',
                          icon: Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.search,
                            title: 'Search by Skills',
                            description: 'Find students with specific skills',
                            color: AppTheme.primaryColor,
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/skill-search');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.assignment,
                            title: 'Assign Internship',
                            description: 'Create and assign internships',
                            color: AppTheme.secondaryColor,
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/assign-internship');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionCard(
                            icon: Icons.verified,
                            title: 'Verify Certificates',
                            description: 'Review pending certificates',
                            color: AppTheme.accentColor,
                            onTap: () {
                              Navigator.pushNamed(context, '/admin/verify-certificates');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'System Overview',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildInfoRow(
                              Icons.people,
                              'Total Students',
                              '${_stats['totalStudents'] ?? 0}',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.business_center,
                              'Students with Internships',
                              '${(_stats['totalStudents'] ?? 0) - (_stats['studentsWithoutInternships'] ?? 0)}',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.warning_amber,
                              'Students without Internships',
                              '${_stats['studentsWithoutInternships'] ?? 0}',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.check_circle,
                              'Completed Internships',
                              '${_stats['completedInternships'] ?? 0}',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.pending_actions,
                              'Pending Certificate Verifications',
                              '${_stats['pendingCertificates'] ?? 0}',
                            ),
                          ],
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
