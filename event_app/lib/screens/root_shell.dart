import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import 'event_screen.dart';
import 'setting_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int idx = 0;
  final pages = const [EventsScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        backgroundColor: const Color(0xFF111111),
        indicatorColor: AppColors.accent.withOpacity(.2),
        onDestinationSelected: (i) => setState(() => idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
