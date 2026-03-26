import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          final stats = adminProvider.stats;

          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  'Welcome, ${adminProvider.currentAdmin?.email}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here\'s an overview of your platform',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Key statistics
                const Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      label: 'Total Users',
                      value: stats.totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      label: 'Total Vendors',
                      value: stats.totalVendors.toString(),
                      icon: Icons.business,
                      color: Colors.green,
                    ),
                    _StatCard(
                      label: 'Pending Approvals',
                      value: stats.pendingVendorApprovals.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      onTap: () => Navigator.of(context)
                          .pushNamed('/admin_vendor_management'),
                    ),
                    _StatCard(
                      label: 'Suspended Users',
                      value: stats.suspendedUsers.toString(),
                      icon: Icons.block,
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Action cards
                const Text(
                  'Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ActionCard(
                  title: 'Manage Users',
                  subtitle: 'View, suspend, or block users',
                  icon: Icons.people_outline,
                  onTap: () =>
                      Navigator.of(context).pushNamed('/admin_user_management'),
                  stats: '${stats.totalUsers} active',
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Manage Vendors',
                  subtitle: 'Approve, reject, or suspend vendors',
                  icon: Icons.business_center,
                  onTap: () => Navigator.of(context)
                      .pushNamed('/admin_vendor_management'),
                  stats: '${stats.pendingVendorApprovals} pending',
                ),
                const SizedBox(height: 12),
                _ActionCard(
                  title: 'Activity Logs',
                  subtitle: 'View all admin actions and user activity',
                  icon: Icons.history,
                  onTap: () =>
                      Navigator.of(context).pushNamed('/admin_activity_logs'),
                  stats: '${adminProvider.activityLogs.length} actions',
                ),
                const SizedBox(height: 32),

                // Financial & Performance
                const Text(
                  'Financial & Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      label: 'Total Revenue',
                      value: '₹${(stats.totalRevenue / 100000).toStringAsFixed(1)}L',
                      icon: Icons.attach_money,
                      color: const Color(0xFF2E7D32),
                    ),
                    _StatCard(
                      label: 'Bookings Completed',
                      value: stats.totalBookingsCompleted.toString(),
                      icon: Icons.check_circle,
                      color: Colors.teal,
                    ),
                    _StatCard(
                      label: 'Avg User Rating',
                      value: stats.averageUserRating.toStringAsFixed(1),
                      icon: Icons.star,
                      color: Colors.amber,
                    ),
                    _StatCard(
                      label: 'Avg Vendor Rating',
                      value: stats.averageVendorRating.toStringAsFixed(1),
                      icon: Icons.star_outline,
                      color: Colors.deepOrange,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<AdminProvider>().adminLogout();
    Navigator.of(context).pushReplacementNamed('/admin_login');
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String stats;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1976D2)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(Icons.arrow_forward_ios, size: 16),
                const SizedBox(height: 8),
                Text(
                  stats,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
