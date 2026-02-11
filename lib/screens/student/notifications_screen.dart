import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/student_service.dart';
import '../../models/user_profile.dart';
import '../../models/notification.dart';
import '../../widgets/app_sidebar.dart';
import 'package:intl/intl.dart';

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
    final userId = _authService.currentUserId;
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

  Future<void> _markAsRead(String id) async {
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
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            currentRoute: '/student/notifications',
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
                  : Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Notifications', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              TextButton.icon(
                                onPressed: _loadData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          if (_notifications.isEmpty)
                            const Expanded(child: Center(child: Text('No notifications yet.')))
                          else
                            Expanded(
                              child: Card(
                                child: ListView.separated(
                                  itemCount: _notifications.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final n = _notifications[index];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: n.isRead ? Colors.grey[200] : AppTheme.primaryColor.withOpacity(0.1),
                                        child: Icon(
                                          _getIcon(n.type),
                                          color: n.isRead ? Colors.grey : AppTheme.primaryColor,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(n.message),
                                          const SizedBox(height: 4),
                                          Text(
                                            DateFormat('MMM dd, yyyy HH:mm').format(n.createdAt),
                                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                          ),
                                        ],
                                      ),
                                      trailing: !n.isRead
                                          ? TextButton(
                                              onPressed: () => _markAsRead(n.id),
                                              child: const Text('Mark as read'),
                                            )
                                          : null,
                                      isThreeLine: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    );
                                  },
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'internship_assigned': return Icons.business_center;
      case 'certificate_verified': return Icons.verified;
      case 'certificate_rejected': return Icons.error;
      default: return Icons.notifications;
    }
  }
}
