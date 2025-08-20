import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

import '../services/deeplink_service.dart';
import 'app_theme.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'high_importance';
  static const String _channelName = 'TEFA Notifications';
  static const String _channelDescription =
      'Important notifications from TEFA app';

  /// Initialize local notifications
  static Future<void> initialize() async {
    // Android settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings (if needed)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    // Combined settings
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    log('Local notifications initialized');
  }

  /// Create notification channel (Android)
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    log('Notification channel created: $_channelId');
  }

  /// Show notification
  static Future<void> showNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create payload from data
      String? payload;
      if (data != null && data.isNotEmpty) {
        // Convert data to simple string format for payload
        if (data.containsKey('order_id')) {
          payload = 'order_${data['order_id']}';
        } else if (data.containsKey('event_id')) {
          payload = 'event_${data['event_id']}';
        }
      }

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            color: AppColors.accent, // Your accent color
          );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000), // Unique ID
        title,
        body,
        details,
        payload: payload,
      );

      log('Local notification shown: $title');
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    log('Notification tapped with payload: ${response.payload}');

    final payload = response.payload;
    if (payload != null) {
      // Handle deep linking based on payload
      _handleNotificationPayload(payload);
    }
  }

  /// Handle notification payload for deep linking
  static void _handleNotificationPayload(String payload) {
    try {
      if (payload.startsWith('event_')) {
        final eventId = payload.replaceFirst('event_', '');
        log('Navigate to event: $eventId');
        _navigateToEvent(eventId);
      }
    } catch (e) {
      log('Error handling notification payload: $e');
    }
  }

  /// Navigate to event detail
  static void _navigateToEvent(String eventId) {
    try {
      final eventIdInt = int.tryParse(eventId);
      if (eventIdInt != null) {
        // Use global navigator key to navigate
        NavigationService.handleDeepLink({'event_id': eventIdInt});
      }
    } catch (e) {
      log('Error navigating to event: $e');
    }
  }

  /// Show scheduled notification (Fixed version)
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create payload
      String? payload;
      if (data != null && data.isNotEmpty) {
        if (data.containsKey('order_id')) {
          payload = 'order_${data['order_id']}';
        } else if (data.containsKey('event_id')) {
          payload = 'event_${data['event_id']}';
        }
      }

      // Android details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
          );

      // Combined details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
      );

      // Convert DateTime to TZDateTime
      final tz.TZDateTime scheduledTZ = tz.TZDateTime.from(
        scheduledTime,
        tz.local,
      );

      // Schedule notification with proper parameters
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      log('Notification scheduled for: $scheduledTime');
    } catch (e) {
      log('Error scheduling notification: $e');
    }
  }

  /// Show immediate notification with specific ID
  static Future<void> showNotificationWithId({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create payload from data
      String? payload;
      if (data != null && data.isNotEmpty) {
        if (data.containsKey('order_id')) {
          payload = 'order_${data['order_id']}';
        } else if (data.containsKey('event_id')) {
          payload = 'event_${data['event_id']}';
        }
      }

      // Android notification details
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@mipmap/ic_launcher',
            color: AppColors.accent,
            // Add big text style for longer content
            styleInformation: BigTextStyleInformation(''),
          );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined details
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification with specific ID
      await _plugin.show(id, title, body, details, payload: payload);

      log('Local notification shown with ID $id: $title');
    } catch (e) {
      log('Error showing notification: $e');
    }
  }

  /// Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    log('Notification cancelled: $id');
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    log('All notifications cancelled');
  }

  /// Get pending notifications
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  static Future<bool?> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return await androidImplementation?.areNotificationsEnabled();
    }
    return true; // iOS handles this differently
  }

  /// Request notification permissions (for Android 13+)
  static Future<bool?> requestNotificationPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation =
          _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return await androidImplementation?.requestNotificationsPermission();
    }
    return true;
  }
}
