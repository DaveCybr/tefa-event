import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  static final _fln = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'high_importance',
    'High Importance',
    description: 'High importance notifications',
    importance: Importance.high,
  );

  static Future<void> init() async {
    await Firebase.initializeApp(); // pastikan google-services.json sudah ada
    final android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    await _fln.initialize(
      InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (resp) async {
        final orderId = resp.payload;
        if (orderId != null) {
          final sp = await SharedPreferences.getInstance();
          await sp.setString('pendingOrderId', orderId);
        }
      },
    );

    await _fln
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    final fm = FirebaseMessaging.instance;
    await fm.requestPermission();
  }

  static Future<void> registerTokenToBackend() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await ApiClient().post(
        '/me/fcm-token',
        data: {
          'token': token,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_id': 'device-${DateTime.now().millisecondsSinceEpoch}',
        },
      );
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newT) async {
      await ApiClient().post(
        '/me/fcm-token/refresh',
        data: {
          'old_token': '', // backend kamu menangani old kosong -> create baru
          'new_token': newT,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
          'device_id': null,
        },
      );
    });
  }

  static Future<void> showLocal(
    String title,
    String body, {
    String? orderId,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
      ),
    );
    await _fln.show(0, title, body, details, payload: orderId);
  }
}

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
