import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final currentUser = authService.currentUser;
    final isDarkMode = ref.watch(darkModeProvider);

    // PERBAIKAN: Gunakan Theme colors
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtitleColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.settings, color: Colors.red[400]),
            const SizedBox(width: 8),
            Text(
              'Settings',
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.red[100],
                  child: Text(
                    currentUser?.email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.userMetadata?['full_name'] ?? 'User',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Appearance Section
          Text(
            'Appearance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  context: context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Aktifkan tema gelap',
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(darkModeProvider.notifier).state = value;
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  context: context,
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  subtitle: 'Dapatkan pemberitahuan tentang produk yang akan kedaluwarsa',
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement notification toggle
                  },
                ),
                Divider(height: 1, color: subtitleColor.withOpacity(0.2)),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.alarm_outlined,
                  title: 'Daily Reminder',
                  subtitle: 'Daily summary at 9:00 AM',
                  value: true,
                  onChanged: (value) {
                    // TODO: Implement daily reminder toggle
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          Text(
            'About',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTile(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About Expiry Keep',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                Divider(height: 1, color: subtitleColor.withOpacity(0.2)),
                _buildTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Kebijakan Privasi',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                Divider(height: 1, color: subtitleColor.withOpacity(0.2)),
                _buildTile(
                  context: context,
                  icon: Icons.description_outlined,
                  title: 'Ketentuan Layanan',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batalkan'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final iconColor = Theme.of(context).colorScheme.onSurfaceVariant;
    
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.red[600],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.access_time_rounded, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Expiry Keep'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Pantau produk Anda dan jangan pernah biarkan kedaluwarsa!',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '© 2026 Expiry Keep. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}