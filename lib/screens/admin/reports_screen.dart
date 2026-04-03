import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  UserProfile? _adminProfile;
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
      _adminProfile = await _authService.getUserProfile(userId);
      _stats = await _adminService.getReportStats();
    }
    setState(() => _isLoading = false);
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
            currentRoute: '/admin/reports',
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
                          const Text(
                            'Analytics & Reports',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),
                          
                          // Summary Row
                          Row(
                            children: [
                              _buildSummaryCard('Total Students', '${_stats['totalStudents'] ?? 0}', Icons.people, AppTheme.primaryColor),
                              const SizedBox(width: 24),
                              _buildSummaryCard('Total Tasks', '${_stats['totalInternships'] ?? 0}', Icons.assignment, AppTheme.secondaryColor),
                              const SizedBox(width: 24),
                              _buildSummaryCard('Completed', '${(_stats['statusStats']?['Completed'] ?? 0)}', Icons.check_circle, AppTheme.successColor),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Detailed Sections
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Department Breakdown
                              Expanded(
                                flex: 1,
                                child: _buildBreakdownCard('Department Distribution', _stats['deptStats'] ?? {}),
                              ),
                              const SizedBox(width: 32),
                              // Year Breakdown
                              Expanded(
                                flex: 1,
                                child: _buildBreakdownCard('Year Distribution', Map<String, int>.from((_stats['yearStats'] ?? {}).map((k, v) => MapEntry('Year $k', v)))),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Task Status Breakdown
                          _buildStatusBreakdown('Internship Status Breakdown', _stats['statusStats'] ?? {}),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownCard(String title, Map<String, int> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            if (data.isEmpty)
              const Center(child: Text('No data available'))
            else
              ...data.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key),
                        Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _stats['totalStudents'] == 0 ? 0 : e.value / _stats['totalStudents'],
                      backgroundColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown(String title, Map<String, int> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.entries.map((e) {
                final color = AppTheme.getStatusColor(e.key);
                return Column(
                  children: [
                    Text(
                      '${e.value}',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(e.key, style: const TextStyle(color: AppTheme.textSecondary)),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
