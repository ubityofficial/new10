import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/admin_theme.dart';

class AdminLayoutWrapper extends StatefulWidget {
  final Widget child;

  const AdminLayoutWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<AdminLayoutWrapper> createState() => _AdminLayoutWrapperState();
}

class _AdminLayoutWrapperState extends State<AdminLayoutWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return widget.child;
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 280,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              color: AdminTheme.surface,
              border: Border(
                right: BorderSide(color: AdminTheme.divider),
              ),
            ),
            child: Column(
              children: [
                // Logo/Header
                Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingLG),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AdminTheme.primary,
                          borderRadius: BorderRadius.circular(
                            AdminTheme.radiusLG,
                          ),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AdminTheme.spacingMD),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'New10',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 12,
                              color: AdminTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AdminTheme.border),
                // Navigation Items
                Expanded(
                  child: ListView(
                    children: [
                      _NavItem(
                        icon: Icons.dashboard_outlined,
                        label: 'Dashboard',
                        isSelected: _selectedIndex == 0,
                        onTap: () {
                          setState(() => _selectedIndex = 0);
                          Navigator.of(context).pushNamed('/admin_dashboard');
                        },
                      ),
                      _NavItem(
                        icon: Icons.people_outline,
                        label: 'Users',
                        isSelected: _selectedIndex == 1,
                        onTap: () {
                          setState(() => _selectedIndex = 1);
                          Navigator.of(context)
                              .pushNamed('/admin_user_management');
                        },
                      ),
                      _NavItem(
                        icon: Icons.business_outlined,
                        label: 'Vendors',
                        isSelected: _selectedIndex == 2,
                        onTap: () {
                          setState(() => _selectedIndex = 2);
                          Navigator.of(context)
                              .pushNamed('/admin_vendor_management');
                        },
                      ),
                      _NavItem(
                        icon: Icons.history_outlined,
                        label: 'Activity Logs',
                        isSelected: _selectedIndex == 3,
                        onTap: () {
                          setState(() => _selectedIndex = 3);
                          Navigator.of(context).pushNamed('/admin_activity_logs');
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AdminTheme.spacingMD,
                          vertical: AdminTheme.spacingLG,
                        ),
                        child: Divider(color: AdminTheme.border),
                      ),
                      _NavItem(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        isSelected: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(AdminTheme.spacingMD),
                  child: Column(
                    children: [
                      const Divider(color: AdminTheme.border),
                      const SizedBox(height: AdminTheme.spacingMD),
                      GestureDetector(
                        onTap: () => _handleLogout(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AdminTheme.spacingMD,
                            vertical: AdminTheme.spacingSM,
                          ),
                          decoration: BoxDecoration(
                            color: AdminTheme.background,
                            borderRadius: BorderRadius.circular(
                              AdminTheme.radiusMD,
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.logout,
                                size: 18,
                                color: AdminTheme.error,
                              ),
                              SizedBox(width: AdminTheme.spacingSM),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AdminTheme.error,
                                  fontWeight: FontWeight.w500,
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
          // Main Content
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AdminProvider>().adminLogout();
    Navigator.of(context).pushReplacementNamed('/admin_login');
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AdminTheme.spacingSM,
          vertical: AdminTheme.spacingXS,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AdminTheme.spacingMD,
          vertical: AdminTheme.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminTheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AdminTheme.radiusMD),
          border: isSelected
              ? Border.all(color: AdminTheme.primary.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AdminTheme.primary : AdminTheme.textSecondary,
            ),
            const SizedBox(width: AdminTheme.spacingMD),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AdminTheme.primary
                    : AdminTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
