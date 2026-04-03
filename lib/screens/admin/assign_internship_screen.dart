import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../models/internship.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/status_badge.dart';

class AssignInternshipScreen extends StatefulWidget {
  const AssignInternshipScreen({super.key});

  @override
  State<AssignInternshipScreen> createState() => _AssignInternshipScreenState();
}

class _AssignInternshipScreenState extends State<AssignInternshipScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  UserProfile? _adminProfile;
  List<UserProfile> _students = [];
  List<UserProfile> _selectedStudents = [];
  bool _isLoading = true;
  bool _isAssigning = false;

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _durationController = TextEditingController();
  final _skillsController = TextEditingController();

  String _selectedDepartment = 'All';
  int? _selectedYear;

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
      _students = await _adminService.getAllStudents();
    }
    setState(() => _isLoading = false);
  }

  List<UserProfile> get _filteredStudents {
    return _students.where((s) {
      final matchesDept = _selectedDepartment == 'All' || s.department == _selectedDepartment;
      final matchesYear = _selectedYear == null || s.year == _selectedYear;
      return matchesDept && matchesYear;
    }).toList();
  }

  Future<void> _assignInternship() async {
    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one student')),
      );
      return;
    }

    if (_titleController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in internship details')),
      );
      return;
    }

    setState(() => _isAssigning = true);

    final adminId = await _authService.currentUserId;
    if (adminId == null) return;
    final success = await _adminService.assignInternshipToStudents(
      title: _titleController.text.trim(),
      company: _companyController.text.trim(),
      role: _roleController.text.trim(),
      duration: _durationController.text.trim(),
      requiredSkills: _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      studentIds: _selectedStudents.map((s) => s.id).toList(),
      adminId: adminId,
    );

    setState(() => _isAssigning = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Internship assigned successfully' : 'Failed to assign internship'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
      if (success) {
        setState(() {
          _selectedStudents.clear();
          _titleController.clear();
          _companyController.clear();
          _roleController.clear();
          _durationController.clear();
          _skillsController.clear();
        });
      }
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
            currentRoute: '/admin/assign-internship',
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
                            'Assign Internship',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Step 1: Internship Details
                                Expanded(
                                  flex: 2,
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Internship Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 24),
                                            TextField(
                                              controller: _titleController,
                                              decoration: const InputDecoration(labelText: 'Project Title', prefixIcon: Icon(Icons.title)),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: _companyController,
                                              decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.business)),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: _roleController,
                                              decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.work_outline)),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: _durationController,
                                              decoration: const InputDecoration(labelText: 'Duration (e.g. 3 Months)', prefixIcon: Icon(Icons.timer_outlined)),
                                            ),
                                            const SizedBox(height: 16),
                                            TextField(
                                              controller: _skillsController,
                                              decoration: const InputDecoration(
                                                labelText: 'Required Skills (Comma separated)',
                                                hintText: 'Flutter, Dart, SQL',
                                                prefixIcon: Icon(Icons.code),
                                              ),
                                            ),
                                            const SizedBox(height: 32),
                                            SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton.icon(
                                                onPressed: _isAssigning ? null : _assignInternship,
                                                icon: _isAssigning 
                                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                  : const Icon(Icons.send),
                                                label: const Text('Assign to Selected Students'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 32),
                                // Step 2: Student Selection
                                Expanded(
                                  flex: 3,
                                  child: Card(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text('Select Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              Text('${_selectedStudents.length} Selected', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        // Filters
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: DropdownButtonFormField<String>(
                                                  value: _selectedDepartment,
                                                  decoration: const InputDecoration(labelText: 'Department', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                                                  items: ['All', ...AppTheme.departments].map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                                                  onChanged: (v) => setState(() => _selectedDepartment = v!),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: DropdownButtonFormField<int?>(
                                                  value: _selectedYear,
                                                  decoration: const InputDecoration(labelText: 'Year', contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                                                  items: [null, 1, 2, 3, 4].map((y) => DropdownMenuItem(value: y, child: Text(y == null ? 'All' : 'Year $y', style: const TextStyle(fontSize: 12)))).toList(),
                                                  onChanged: (v) => setState(() => _selectedYear = v),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        Expanded(
                                          child: ListView.builder(
                                            itemCount: _filteredStudents.length,
                                            itemBuilder: (context, index) {
                                              final student = _filteredStudents[index];
                                              final isSelected = _selectedStudents.any((s) => s.id == student.id);
                                              return CheckboxListTile(
                                                title: Text(student.name),
                                                subtitle: Text('${student.department} • Year ${student.year}'),
                                                value: isSelected,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      _selectedStudents.add(student);
                                                    } else {
                                                      _selectedStudents.removeWhere((s) => s.id == student.id);
                                                    }
                                                  });
                                                },
                                                secondary: CircleAvatar(
                                                  radius: 18,
                                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                                  child: Text(student.name[0].toUpperCase(), style: const TextStyle(fontSize: 14)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _roleController.dispose();
    _durationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }
}
