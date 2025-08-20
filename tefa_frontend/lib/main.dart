import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/event_provider.dart';
import 'providers/setting_provider.dart';
import 'screens/splashscreen.dart';
import 'services/deeplink_service.dart';
import 'services/fcm_service.dart';
import 'services/storage_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  tz.initializeTimeZones();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await StorageService.init();

  await FCMService.initialize();

  runApp(const TefaApp());
}

class TefaApp extends StatelessWidget {
  const TefaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => EventDetailProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'TEFA Mobile App',
        theme: buildTheme(),
        home: const SplashScreen(),
        navigatorKey: NavigationService.navigatorKey,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
