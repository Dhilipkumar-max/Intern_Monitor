import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final userId = await _authService.currentUserId;
    if (userId != null) {
      final profile = await _authService.getUserProfile(userId);
      if (profile != null) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name;
          _phoneController.text = profile.phoneNumber ?? '';
          _departmentController.text = profile.department ?? '';
          _yearController.text = profile.year?.toString() ?? '';
          _githubController.text = profile.githubUrl ?? '';
          _linkedinController.text = profile.linkedinUrl ?? '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final userId = await _authService.currentUserId;
    if (userId != null) {
      final success = await _authService.updateProfile(userId, {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': int.tryParse(_yearController.text.trim()),
        'github_url': _githubController.text.trim(),
        'linkedin_url': _linkedinController.text.trim(),
      });

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Profile updated successfully'
                  : 'Failed to update profile',
            ),
            backgroundColor: success
                ? AppTheme.successColor
                : AppTheme.errorColor,
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
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            AppSidebar(
              currentRoute: '/student/profile',
              items: _buildSidebarItems(),
              onLogout: _handleLogout,
              userName: _profile?.name ?? 'Student',
              userEmail: _profile?.email ?? '',
            ),

          Expanded(
            child: Container(
              color: AppTheme.backgroundColor,
              child: CustomScrollView(
                slivers: [
                  _buildTopAppBar(isMobile),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 48,
                      vertical: 32,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(),
                        const SizedBox(height: 32),
                        _buildProfileForm(isMobile),
                        const SizedBox(height: 100),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNavBar() : null,
    );
  }

  List<SidebarItem> _buildSidebarItems() {
    return [
      SidebarItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/student/dashboard'),
      SidebarItem(icon: Icons.person_rounded, label: 'Profile', route: '/student/profile'),
      SidebarItem(icon: Icons.code_rounded, label: 'Skills', route: '/student/skills'),
      SidebarItem(icon: Icons.description_rounded, label: 'Resume', route: '/student/resume'),
      SidebarItem(icon: Icons.workspace_premium_rounded, label: 'Certificates', route: '/student/certificates'),
      SidebarItem(icon: Icons.business_center_rounded, label: 'Internship', route: '/student/internship'),
      SidebarItem(icon: Icons.rocket_launch_rounded, label: 'Projects', route: '/student/projects'),
      SidebarItem(icon: Icons.notifications_rounded, label: 'Notifications', route: '/student/notifications'),
    ];
  }

  Widget _buildTopAppBar(bool isMobile) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white.withOpacity(0.7),
      surfaceTintColor: Colors.transparent,
      leading: isMobile 
        ? IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor),
            onPressed: () {},
          )
        : null,
      title: isMobile 
        ? Text('Profile', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppTheme.primaryColor))
        : null,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCOUNT SETTINGS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Personal Information',
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm(bool isMobile) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 48),
              _buildFormSectionTitle('Basic Details'),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _nameController,
                label: 'FULL NAME',
                icon: Icons.person_outline_rounded,
                validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
              ),
              const SizedBox(height: 24),
              _buildReadOnlyField(
                label: 'REGISTER NUMBER',
                value: _profile?.registerNumber ?? 'N/A',
                icon: Icons.assignment_ind_outlined,
              ),
              const SizedBox(height: 24),
              _buildDropdownField(),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _yearController,
                label: 'ACADEMIC YEAR',
                icon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 48),
              _buildFormSectionTitle('Professional Links'),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _githubController,
                label: 'GITHUB PROFILE URL',
                icon: Icons.code_rounded,
                hint: 'https://github.com/username',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _linkedinController,
                label: 'LINKEDIN PROFILE URL',
                icon: Icons.business_rounded,
                hint: 'https://linkedin.com/in/username',
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _phoneController,
                label: 'PHONE NUMBER',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 48),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  _profile?.name.isNotEmpty == true ? _profile!.name[0].toUpperCase() : 'S',
                  style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _profile?.email ?? '',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Verified Account',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppTheme.textSecondary,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 12),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock_rounded, size: 14, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEPARTMENT',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _departmentController.text.isEmpty ? null : _departmentController.text,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.school_outlined, size: 20),
          ),
          items: AppTheme.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: (value) => setState(() => _departmentController.text = value!),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Save Changes', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: _loadProfile,
            padding: const EdgeInsets.all(18),
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
            tooltip: 'Reset Profile',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard_rounded, 'Home', false, route: '/student/dashboard'),
          _buildNavItem(Icons.rocket_launch_rounded, 'Projects', false, route: '/student/projects'),
          _buildNavItem(Icons.workspace_premium_rounded, 'Certs', false, route: '/student/certificates'),
          _buildNavItem(Icons.person_rounded, 'Profile', true, route: '/student/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {required String route}) {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary.withOpacity(0.5),
              letterSpacing: 0.5,
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
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }
}
