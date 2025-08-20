import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/root_shell.dart';
import 'screens/order_detail_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FcmService.init();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Widget _home = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _decideStart();
  }

  Future<void> _decideStart() async {
    final sp = await SharedPreferences.getInstance();
    final pendingOrderId = sp.getString('pendingOrderId');
    if (pendingOrderId != null) {
      _home = OrderDetailScreen(orderId: int.parse(pendingOrderId));
      await sp.remove('pendingOrderId');
    } else {
      if ((sp.getString('token') ?? '').isNotEmpty) _home = const RootShell();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Event App', theme: buildTheme(), home: _home);
  }
}
