import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_theme.dart';
import '../services/api_client.dart';
import '../services/fcm_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool allowNotif = true;
  String token = '-';

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    allowNotif = sp.getBool('allowNotif') ?? true;
    try {
      final res = await ApiClient().get('/me/fcm-tokens');
      final list = (res.data as Map)['data'] as List;
      token = list.isNotEmpty ? list.first['token'] : token;
    } catch (_) {}
    setState(() => {});
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext ctx) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Terima Notifikasi', style: TextStyle(fontSize: 16)),
              const Spacer(),
              Switch(
                value: allowNotif,
                activeColor: AppColors.accent,
                onChanged: (v) async {
                  final sp = await SharedPreferences.getInstance();
                  await sp.setBool('allowNotif', v);
                  setState(() => allowNotif = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151515),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('FCM token', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  token,
                  style: const TextStyle(color: AppColors.gray),
                ),
              ),
              TextButton(
                onPressed: () {
                  FcmService.showLocal('Copied', 'Token copied');
                },
                child: const Text(
                  'Copy',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
