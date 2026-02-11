import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../models/skill.dart';
import '../../widgets/app_sidebar.dart';

class StudentSkillsScreen extends StatefulWidget {
  const StudentSkillsScreen({super.key});

  @override
  State<StudentSkillsScreen> createState() => _StudentSkillsScreenState();
}

class _StudentSkillsScreenState extends State<StudentSkillsScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _profile;
  List<Skill> _skills = [];
  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _skillNameController = TextEditingController();
  String _selectedLevel = 'Beginner';
  Skill? _editingSkill;

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
      final skills = await _studentService.getSkills(userId);

      setState(() {
        _profile = profile;
        _skills = skills;
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateSkill() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = _authService.currentUserId;
    if (userId == null) return;

    bool success;
    if (_editingSkill != null) {
      success = await _studentService.updateSkill(
        _editingSkill!.id,
        _skillNameController.text.trim(),
        _selectedLevel,
      );
    } else {
      success = await _studentService.addSkill(
        userId,
        _skillNameController.text.trim(),
        _selectedLevel,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? _editingSkill != null
                  ? 'Skill updated successfully'
                  : 'Skill added successfully'
              : 'Failed to save skill'),
          backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );

      if (success) {
        _skillNameController.clear();
        setState(() {
          _selectedLevel = 'Beginner';
          _editingSkill = null;
        });
        _loadData();
      }
    }
  }

  Future<void> _deleteSkill(Skill skill) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Skill'),
        content: Text('Are you sure you want to delete "${skill.skillName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _studentService.deleteSkill(skill.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Skill deleted' : 'Failed to delete skill'),
            backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
        if (success) _loadData();
      }
    }
  }

  void _startEdit(Skill skill) {
    setState(() {
      _editingSkill = skill;
      _skillNameController.text = skill.skillName;
      _selectedLevel = skill.skillLevel;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingSkill = null;
      _skillNameController.clear();
      _selectedLevel = 'Beginner';
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
            currentRoute: '/student/skills',
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
                          const Text(
                            'Skills Management',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add and manage your technical and professional skills',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Add/Edit Form
                              Expanded(
                                flex: 2,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _editingSkill != null ? 'Edit Skill' : 'Add New Skill',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 20),

                                          TextFormField(
                                            controller: _skillNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Skill Name *',
                                              hintText: 'e.g., Flutter, Python, UI/UX Design',
                                              prefixIcon: Icon(Icons.code),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter a skill name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 20),

                                          DropdownButtonFormField<String>(
                                            value: _selectedLevel,
                                            decoration: const InputDecoration(
                                              labelText: 'Skill Level *',
                                              prefixIcon: Icon(Icons.bar_chart),
                                            ),
                                            items: ['Beginner', 'Intermediate', 'Advanced']
                                                .map((level) => DropdownMenuItem(
                                                      value: level,
                                                      child: Text(level),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() => _selectedLevel = value!);
                                            },
                                          ),
                                          const SizedBox(height: 24),

                                          Row(
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: _addOrUpdateSkill,
                                                icon: Icon(_editingSkill != null ? Icons.save : Icons.add),
                                                label: Text(_editingSkill != null ? 'Update Skill' : 'Add Skill'),
                                              ),
                                              if (_editingSkill != null) ...[
                                                const SizedBox(width: 12),
                                                OutlinedButton.icon(
                                                  onPressed: _cancelEdit,
                                                  icon: const Icon(Icons.cancel),
                                                  label: const Text('Cancel'),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),

                              // Skills List
                              Expanded(
                                flex: 3,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Your Skills',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${_skills.length} Skills',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),

                                        if (_skills.isEmpty)
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(32),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.code_off,
                                                    size: 64,
                                                    color: AppTheme.textSecondary.withOpacity(0.5),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'No skills added yet',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Add your first skill using the form',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppTheme.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 12,
                                            children: _skills.map((skill) {
                                              return _buildSkillCard(skill);
                                            }).toList(),
                                          ),
                                      ],
                                    ),
                                  ),
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

  Widget _buildSkillCard(Skill skill) {
    Color levelColor;
    switch (skill.skillLevel) {
      case 'Advanced':
        levelColor = AppTheme.successColor;
        break;
      case 'Intermediate':
        levelColor = AppTheme.infoColor;
        break;
      default:
        levelColor = AppTheme.warningColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.skillName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () => _startEdit(skill),
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                    onTap: () => _deleteSkill(skill),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: levelColor.withOpacity(0.3)),
            ),
            child: Text(
              skill.skillLevel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: levelColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _skillNameController.dispose();
    super.dispose();
  }
}
