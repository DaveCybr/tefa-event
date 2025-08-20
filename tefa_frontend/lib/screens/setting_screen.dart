import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../core/app_theme.dart';
import '../providers/setting_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();

    // Load settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().initializeSettings();
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.white),
            ),
            content: const Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: AppColors.gray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await context.read<AuthProvider>().logout();

                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  void _showTokenDialog() {
    final settingsProvider = context.read<SettingsProvider>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF111111),
            title: const Text(
              'FCM Token',
              style: TextStyle(color: AppColors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Firebase Cloud Messaging token:',
                  style: TextStyle(color: AppColors.gray, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dark.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.dark),
                  ),
                  child: SelectableText(
                    settingsProvider.fcmTokenDisplay,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This token is used to send push notifications to your device.',
                  style: TextStyle(color: AppColors.gray, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  settingsProvider.copyFcmToken();
                  Navigator.of(context).pop();
                },
                child: const Text('Copy'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Card
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.dark.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.accent,
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.name ?? 'User',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user?.role.toUpperCase() ?? '',
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Notifications Section
            const Text(
              'Notifications',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dark.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      // Notification Toggle
                      ListTile(
                        leading: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.white,
                        ),
                        title: const Text(
                          'Receive Notifications',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Enable push notifications for events and updates',
                          style: TextStyle(color: AppColors.gray, fontSize: 12),
                        ),
                        trailing: Switch(
                          value: settingsProvider.notificationsEnabled,
                          onChanged: settingsProvider.toggleNotifications,
                          activeColor: AppColors.accent,
                          activeTrackColor: AppColors.accent.withOpacity(0.3),
                          inactiveThumbColor: AppColors.gray,
                          inactiveTrackColor: AppColors.dark,
                        ),
                      ),

                      Divider(
                        color: AppColors.dark.withOpacity(0.3),
                        height: 1,
                      ),

                      // FCM Token
                      ListTile(
                        leading: const Icon(
                          Icons.token_outlined,
                          color: AppColors.white,
                        ),
                        title: const Text(
                          'FCM Token',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              settingsProvider.fcmTokenTruncated,
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                            if (settingsProvider.tokenCopied) ...[
                              const SizedBox(height: 4),
                              const Text(
                                'Token copied to clipboard!',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.copy,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              onPressed: settingsProvider.copyFcmToken,
                              tooltip: 'Copy token',
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.visibility,
                                color: AppColors.gray,
                                size: 20,
                              ),
                              onPressed: _showTokenDialog,
                              tooltip: 'View full token',
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        color: AppColors.dark.withOpacity(0.3),
                        height: 1,
                      ),

                      // Refresh Token
                      ListTile(
                        leading: const Icon(
                          Icons.refresh,
                          color: AppColors.white,
                        ),
                        title: const Text(
                          'Refresh Token',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: const Text(
                          'Get a new FCM token if notifications aren\'t working',
                          style: TextStyle(color: AppColors.gray, fontSize: 12),
                        ),
                        trailing:
                            settingsProvider.isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accent,
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.gray,
                                ),
                        onTap:
                            settingsProvider.isLoading
                                ? null
                                : settingsProvider.refreshFcmToken,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // App Information Section
            const Text(
              'App Information',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dark.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // App Version
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: AppColors.white),
                    title: Text(
                      'App Version',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '1.0.0',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ),

                  Divider(color: AppColors.dark.withOpacity(0.3), height: 1),

                  // Privacy Policy
                  ListTile(
                    leading: const Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.white,
                    ),
                    title: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.gray,
                    ),
                    onTap: () {
                      // Navigate to privacy policy
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Privacy Policy feature coming soon'),
                          backgroundColor: AppColors.dark,
                        ),
                      );
                    },
                  ),

                  Divider(color: AppColors.dark.withOpacity(0.3), height: 1),

                  // Terms of Service
                  ListTile(
                    leading: const Icon(
                      Icons.description_outlined,
                      color: AppColors.white,
                    ),
                    title: const Text(
                      'Terms of Service',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.gray,
                    ),
                    onTap: () {
                      // Navigate to terms of service
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Terms of Service feature coming soon'),
                          backgroundColor: AppColors.dark,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danger Zone Section
            const Text(
              'Account',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // Logout
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out from your account',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.error,
                    ),
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'Event Management App',
                    style: TextStyle(
                      color: AppColors.gray.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made by DaveCybr.',
                    style: TextStyle(
                      color: AppColors.gray.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
