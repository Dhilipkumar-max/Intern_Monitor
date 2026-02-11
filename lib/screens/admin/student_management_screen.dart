import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  UserProfile? _adminProfile;
  List<UserProfile> _allStudents = [];
  List<UserProfile> _filteredStudents = [];
  bool _isLoading = true;

  final _searchController = TextEditingController();
  String _selectedDepartment = 'All';
  int? _selectedYear;

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
      _allStudents = await _adminService.getAllStudents();
      _applyFilters();
    }
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        final matchesSearch = student.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            (student.registerNumber?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false);
        final matchesDept = _selectedDepartment == 'All' || student.department == _selectedDepartment;
        final matchesYear = _selectedYear == null || student.year == _selectedYear;
        return matchesSearch && matchesDept && matchesYear;
      }).toList();
    });
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
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Student Management',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),
                          
                          // Filters Bar
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: const InputDecoration(
                                        hintText: 'Search by name or register number...',
                                        prefixIcon: Icon(Icons.search),
                                      ),
                                      onChanged: (_) => _applyFilters(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      value: _selectedDepartment,
                                      decoration: const InputDecoration(labelText: 'Department'),
                                      items: ['All', ...AppTheme.departments]
                                          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                          .toList(),
                                      onChanged: (val) {
                                        _selectedDepartment = val!;
                                        _applyFilters();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 1,
                                    child: DropdownButtonFormField<int?>(
                                      value: _selectedYear,
                                      decoration: const InputDecoration(labelText: 'Year'),
                                      items: [null, 1, 2, 3, 4]
                                          .map((y) => DropdownMenuItem(value: y, child: Text(y == null ? 'All' : 'Year $y')))
                                          .toList(),
                                      onChanged: (val) {
                                        _selectedYear = val;
                                        _applyFilters();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Students Table
                          Expanded(
                            child: Card(
                              child: _filteredStudents.isEmpty
                                  ? const Center(child: Text('No students found.'))
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        showCheckboxColumn: false,
                                        columns: const [
                                          DataColumn(label: Text('Name')),
                                          DataColumn(label: Text('Reg. Number')),
                                          DataColumn(label: Text('Department')),
                                          DataColumn(label: Text('Year')),
                                          DataColumn(label: Text('Completion')),
                                          DataColumn(label: Text('Actions')),
                                        ],
                                        rows: _filteredStudents.map((student) {
                                          return DataRow(
                                            onSelectChanged: (_) {
                                              Navigator.pushNamed(context, '/admin/student-detail', arguments: student);
                                            },
                                            cells: [
                                              DataCell(Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                              DataCell(Text(student.registerNumber ?? 'N/A')),
                                              DataCell(Text(student.department ?? 'N/A')),
                                              DataCell(Text(student.year?.toString() ?? 'N/A')),
                                              DataCell(
                                                LinearProgressIndicator(
                                                  value: (student.profileCompletion ?? 0) / 100,
                                                  backgroundColor: Colors.grey[200],
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    _getCompletionColor(student.profileCompletion ?? 0),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.message_outlined, size: 20, color: AppTheme.primaryColor),
                                                      onPressed: () => _showSendMessageDialog(student),
                                                      tooltip: 'Send Message',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                                                      onPressed: () {
                                                        Navigator.pushNamed(context, '/admin/student-detail', arguments: student);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
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

  Future<void> _showSendMessageDialog(UserProfile student) async {
    final titleController = TextEditingController(text: 'Message from Admin');
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.message_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text('Message ${student.name.split(' ')[0]}'),
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
                studentId: student.id,
                title: titleController.text,
                message: messageController.text,
              );

              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent successfully'),
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

  Color _getCompletionColor(int value) {
    if (value >= 80) return AppTheme.successColor;
    if (value >= 50) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }
}
