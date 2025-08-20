import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/notifications_helper.dart';
import 'api_client.dart';
import 'deeplink_service.dart';
import 'storage_service.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  // static final FlutterLocalNotificationsPlugin _localNotifications =
  //     FlutterLocalNotificationsPlugin();

  static String? _currentToken;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _requestPermission();

      await NotificationHelper.initialize();

      await _getToken();

      await _setupMessageHandlers();

      _setupTokenRefreshListener();

      _isInitialized = true;
      log('FCM Service initialized successfully');
    } catch (e) {
      log('FCM initialization error: $e');
    }
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('FCM Permission status: ${settings.authorizationStatus}');
  }

  static Future<String?> _getToken() async {
    try {
      _currentToken = await _messaging.getToken();
      log('FCM Token: $_currentToken');

      if (_currentToken != null) {
        await StorageService.saveFcmToken(_currentToken!);

        await _sendTokenToBackend(_currentToken!);
      }

      return _currentToken;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> _sendTokenToBackend(String token) async {
    try {
      final userToken = StorageService.getToken();
      if (userToken == null) return;

      await ApiService.storeFcmToken(
        token: userToken,
        fcmToken: token,
        deviceType: 'android',
        deviceId: StorageService.getDeviceId(),
      );

      log('FCM token sent to backend successfully');
    } catch (e) {
      log('Error sending FCM token to backend: $e');
    }
  }

  static Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Foreground message received: ${message.messageId}');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');

    final notificationsEnabled = StorageService.getNotificationsEnabled();
    if (!notificationsEnabled) {
      log('Notifications disabled by user');
      return;
    }

    await NotificationHelper.showNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? 'You have a new message',
      data: message.data,
    );
  }

  static Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    log('Message opened app: ${message.messageId}');
    log('Data: ${message.data}');

    // Gunakan NavigationService
    await NavigationService.handleDeepLink(message.data);
  }

  static void _setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      log('FCM Token refreshed: $newToken');

      final oldToken = _currentToken;
      _currentToken = newToken;
      await StorageService.saveFcmToken(newToken);

      if (oldToken != null) {
        await _refreshTokenOnBackend(oldToken, newToken);
      } else {
        await _sendTokenToBackend(newToken);
      }
    });
  }

  static Future<void> _refreshTokenOnBackend(
    String oldToken,
    String newToken,
  ) async {
    try {
      final userToken = StorageService.getToken();
      if (userToken == null) return;

      await ApiService.refreshFcmToken(
        token: userToken,
        oldToken: oldToken,
        newToken: newToken,
        deviceType: 'android',
        deviceId: StorageService.getDeviceId(),
      );

      log('FCM token refreshed on backend successfully');
    } catch (e) {
      log('Error refreshing FCM token on backend: $e');
    }
  }

  static String? getCurrentToken() {
    return _currentToken ?? StorageService.getFcmToken();
  }

  static Future<String?> refreshToken() async {
    try {
      await _messaging.deleteToken();
      return await _getToken();
    } catch (e) {
      log('Error refreshing token manually: $e');
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      log('Subscribed to topic: $topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      log('Unsubscribed from topic: $topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log('Background message received: ${message.messageId}');
  log('Title: ${message.notification?.title}');
  log('Body: ${message.notification?.body}');
  log('Data: ${message.data}');
}
