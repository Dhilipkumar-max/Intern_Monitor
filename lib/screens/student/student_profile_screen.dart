import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../widgets/app_sidebar.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final userId = _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (profile != null) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
          _phoneController.text = profile.phoneNumber ?? '';
          _departmentController.text = profile.department ?? '';
          _yearController.text = profile.year?.toString() ?? '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userId = _authService.currentUserId;
    if (userId != null) {
      final success = await _authService.updateProfile(userId, {
        'name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': int.tryParse(_yearController.text.trim()),
      });

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Profile updated successfully' : 'Failed to update profile'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          _loadProfile();
        }
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
            currentRoute: '/student/profile',
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
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage your personal information',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Form
                    Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Picture
                                Center(
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundColor: AppTheme.primaryColor,
                                        child: Text(
                                          _profile?.name[0].toUpperCase() ?? 'S',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _profile?.email ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                const Divider(),
                                const SizedBox(height: 32),

                                // Name
                                TextFormField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name *',
                                    hintText: 'Enter your full name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Register Number (Read-only)
                                TextFormField(
                                  initialValue: _profile?.registerNumber ?? 'N/A',
                                  decoration: const InputDecoration(
                                    labelText: 'Register Number',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  enabled: false,
                                ),
                                const SizedBox(height: 20),

                                // Department
                                DropdownButtonFormField<String>(
                                  value: _departmentController.text.isEmpty ? null : _departmentController.text,
                                  decoration: const InputDecoration(
                                    labelText: 'Department',
                                    prefixIcon: Icon(Icons.school_outlined),
                                  ),
                                  items: AppTheme.departments
                                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _departmentController.text = value!;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your department';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Year
                                TextFormField(
                                  controller: _yearController,
                                  decoration: const InputDecoration(
                                    labelText: 'Year',
                                    hintText: 'e.g., 3',
                                    prefixIcon: Icon(Icons.calendar_today_outlined),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final year = int.tryParse(value);
                                      if (year == null || year < 1 || year > 5) {
                                        return 'Please enter a valid year (1-5)';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                // Phone Number
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: 'Enter your phone number',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 32),

                                // Save Button
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _isSaving ? null : _saveProfile,
                                      icon: _isSaving
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.save),
                                      label: const Text('Save Changes'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: _loadProfile,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Reset'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
