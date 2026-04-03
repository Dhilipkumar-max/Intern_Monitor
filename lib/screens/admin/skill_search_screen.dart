import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';

class SkillBasedSearchScreen extends StatefulWidget {
  const SkillBasedSearchScreen({super.key});

  @override
  State<SkillBasedSearchScreen> createState() => _SkillBasedSearchScreenState();
}

class _SkillBasedSearchScreenState extends State<SkillBasedSearchScreen> {
  final AuthService _authService = AuthService();
  final AdminService _adminService = AdminService();

  UserProfile? _adminProfile;
  List<UserProfile> _searchResults = [];
  bool _isLoading = false;
  bool _initialLoad = true;

  final _skillController = TextEditingController();
  String _skillLevel = 'All';
  String _selectedDepartment = 'All';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = await _authService.currentUserId;
    if (userId != null) {
      _adminProfile = await _authService.getUserProfile(userId);
    }
    setState(() => _initialLoad = false);
  }

  Future<void> _search() async {
    if (_skillController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final results = await _adminService.searchStudentsBySkill(
      skillName: _skillController.text.trim(),
      skillLevel: _skillLevel == 'All' ? null : _skillLevel,
      department: _selectedDepartment == 'All' ? null : _selectedDepartment,
    );
    setState(() {
      _searchResults = results.map((e) => e['student'] as UserProfile).toList();
      _isLoading = false;
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
            currentRoute: '/admin/skill-search',
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
            userName: _adminProfile?.name ?? 'Admin',
            userEmail: _adminProfile?.email ?? '',
          ),
          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: _initialLoad
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Skill-Based Search',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Find the best candidates by matching specific skills and expertise levels.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 32),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextField(
                                          controller: _skillController,
                                          decoration: const InputDecoration(
                                            labelText: 'Enter Skill',
                                            hintText:
                                                'e.g., Flutter, Python, SQL',
                                            prefixIcon: Icon(Icons.code),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          value: _skillLevel,
                                          decoration: const InputDecoration(
                                            labelText: 'Min Level',
                                          ),
                                          items:
                                              [
                                                    'All',
                                                    'Beginner',
                                                    'Intermediate',
                                                    'Advanced',
                                                    'Expert',
                                                  ]
                                                  .map(
                                                    (l) => DropdownMenuItem(
                                                      value: l,
                                                      child: Text(l),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) => setState(
                                            () => _skillLevel = val!,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        flex: 2,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedDepartment,
                                          decoration: const InputDecoration(
                                            labelText: 'Department',
                                          ),
                                          items:
                                              ['All', ...AppTheme.departments]
                                                  .map(
                                                    (d) => DropdownMenuItem(
                                                      value: d,
                                                      child: Text(d),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (val) => setState(
                                            () => _selectedDepartment = val!,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        height: 56,
                                        width: 120,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _search,
                                          child: _isLoading
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Text('Search'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (_searchResults.isEmpty && !_isLoading)
                            const Expanded(
                              child: Center(
                                child: Text(
                                  'Enter a skill to find matching students.',
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                      childAspectRatio: 2.5,
                                    ),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final student = _searchResults[index];
                                  return Card(
                                    child: InkWell(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/admin/student-detail',
                                        arguments: student,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: AppTheme
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              child: Text(
                                                student.name[0].toUpperCase(),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    student.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    student.department ??
                                                        'No Department',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppTheme
                                                          .textSecondary,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 16,
                                            ),
                                          ],
                                        ),
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
