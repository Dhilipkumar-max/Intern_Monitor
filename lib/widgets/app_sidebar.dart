import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppSidebar extends StatelessWidget {
  final String currentRoute;
  final List<SidebarItem> items;
  final VoidCallback onLogout;
  final String userName;
  final String userEmail;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.items,
    required this.onLogout,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        border: Border(
          right: BorderSide(color: AppTheme.surfaceContainerHigh, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(32, 48, 32, 32),
            child: Row(
              children: [
                Hero(
                  tag: 'app_logo',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'InternInfo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: items.map((item) {
                final isActive = currentRoute == item.route;
                return _SidebarNavItem(
                  icon: item.icon,
                  label: item.label,
                  route: item.route,
                  isActive: isActive,
                );
              }).toList(),
            ),
          ),

          // User Profile & Logout
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppTheme.surfaceContainerHigh, width: 1),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: theme.textTheme.labelLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              userEmail,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.tertiaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.tertiaryColor.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            if (!widget.isActive) {
              Navigator.pushReplacementNamed(context, widget.route);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isActive 
                ? AppTheme.primaryColor.withOpacity(0.15) 
                : (_isHovered ? Colors.white.withOpacity(0.05) : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isActive 
                  ? AppTheme.primaryColor.withOpacity(0.3) 
                  : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.isActive 
                    ? AppTheme.primaryColor 
                    : ( _isHovered ? Colors.white : AppTheme.sidebarText),
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.isActive 
                      ? Colors.white 
                      : (_isHovered ? Colors.white : AppTheme.sidebarText),
                    fontWeight: widget.isActive ? FontWeight.w700 : (_isHovered ? FontWeight.w500 : FontWeight.w400),
                    fontSize: 14,
                  ),
                ),
                if (widget.isActive) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String label;
  final String route;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
