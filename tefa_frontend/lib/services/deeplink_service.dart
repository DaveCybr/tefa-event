import 'package:flutter/material.dart';
import '../screens/event_detail_screen.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Handle deep link from FCM notification
  static Future<void> handleDeepLink(Map<String, dynamic> data) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    try {
      if (data.containsKey('event_id')) {
        final eventId = int.tryParse(data['event_id'].toString());
        if (eventId != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventId: eventId),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Deep link navigation error: $e');
    }
  }

  /// Handle pending navigation (dari storage)
  static Future<void> handlePendingNavigation() async {
    // Implementasi untuk handle navigation yang pending
    // saat app dibuka dari terminated state
  }
}
