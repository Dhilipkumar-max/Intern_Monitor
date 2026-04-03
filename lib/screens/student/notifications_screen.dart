import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../models/notification.dart';
import '../../widgets/app_sidebar.dart';
import 'package:intl/intl.dart';

import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();
  final StudentService _studentService = StudentService();

  UserProfile? _profile;
  List<AppNotification> _notifications = [];
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
      final notifications = await _studentService.getNotifications(userId);
      setState(() {
        _profile = profile;
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    await _studentService.markNotificationAsRead(id);
    await _loadData();
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
              currentRoute: '/student/notifications',
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
                        _buildHeader(isMobile),
                        const SizedBox(height: 48),
                        if (_notifications.isEmpty)
                          _buildEmptyState()
                        else
                          ..._notifications.map((n) => _buildNotificationCard(n)).toList(),
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
      SidebarItem(icon: Icons.notifications_rounded, label: 'Notifications', route: '/student/notifications'),
    ];
  }

  Widget _buildTopAppBar(bool isMobile) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      surfaceTintColor: Colors.transparent,
      leading: isMobile 
        ? IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryColor),
            onPressed: () {},
          )
        : null,
      title: isMobile 
        ? Text('Notifications', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: AppTheme.primaryColor))
        : null,
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPDATES & COMMUNICATIONS',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Academic Feed',
          style: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            'All Caught Up',
            style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'No new academic notifications at this time. We\'ll alert you when there are updates.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification n) {
    final bool isUnread = !n.isRead;
    final Color statusColor = _getStatusColor(n.type ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : AppTheme.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnread ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.borderColor.withOpacity(0.5),
        ),
        boxShadow: isUnread ? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ] : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_getIcon(n.type ?? ''), color: statusColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n.title?.toUpperCase() ?? 'NOTIFICATION',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, hh:mm a').format(n.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => _markAsRead(n.id),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: Text('Mark as read', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 12, top: 2),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'internship_assigned': return AppTheme.primaryColor;
      case 'certificate_verified': return AppTheme.successColor;
      case 'certificate_rejected': return AppTheme.errorColor;
      default: return AppTheme.textSecondary;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'internship_assigned': return Icons.business_center_rounded;
      case 'certificate_verified': return Icons.verified_rounded;
      case 'certificate_rejected': return Icons.error_rounded;
      default: return Icons.notifications_rounded;
    }
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
          _buildNavItem(Icons.notifications_rounded, 'Updates', true, route: '/student/notifications'),
          _buildNavItem(Icons.workspace_premium_rounded, 'Certs', false, route: '/student/certificates'),
          _buildNavItem(Icons.person_rounded, 'Profile', false, route: '/student/profile'),
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
}
