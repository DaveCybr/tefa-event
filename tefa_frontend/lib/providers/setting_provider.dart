import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../services/fcm_service.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  String? _fcmToken;
  bool _isLoading = false;
  String? _errorMessage;
  bool _tokenCopied = false;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  String? get fcmToken => _fcmToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get tokenCopied => _tokenCopied;
  String get fcmTokenDisplay => _fcmToken ?? 'Token not available';

  /// Initialize settings
  Future<void> initializeSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load notification preference
      _notificationsEnabled = StorageService.getNotificationsEnabled();

      // Load FCM token
      _fcmToken = StorageService.getFcmToken();

      // If no token in storage, get current token
      if (_fcmToken == null) {
        _fcmToken = FCMService.getCurrentToken();
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load settings: $e';
      debugPrint('Settings initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;

    try {
      // Save to storage
      await StorageService.setNotificationsEnabled(enabled);

      _errorMessage = null;
      notifyListeners();

      debugPrint('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      // Revert on error
      _notificationsEnabled = !enabled;
      _errorMessage = 'Failed to update notification settings';
      debugPrint('Toggle notifications error: $e');
      notifyListeners();
    }
  }

  /// Refresh FCM token
  Future<void> refreshFcmToken() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get new token from FCM service
      final newToken = await FCMService.refreshToken();

      if (newToken != null) {
        _fcmToken = newToken;
        _errorMessage = null;

        // Show success message (temporary)
        _showTemporaryMessage('Token refreshed successfully');
      } else {
        _errorMessage = 'Failed to refresh token';
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh token: $e';
      debugPrint('Refresh FCM token error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Copy FCM token to clipboard
  Future<void> copyFcmToken() async {
    if (_fcmToken == null) {
      _errorMessage = 'No token available to copy';
      notifyListeners();
      return;
    }

    try {
      await Clipboard.setData(ClipboardData(text: _fcmToken!));

      // Show copied indicator
      _tokenCopied = true;
      notifyListeners();

      // Reset copied indicator after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _tokenCopied = false;
        notifyListeners();
      });

      debugPrint('FCM token copied to clipboard');
    } catch (e) {
      _errorMessage = 'Failed to copy token';
      debugPrint('Copy token error: $e');
      notifyListeners();
    }
  }

  /// Show temporary success message
  void _showTemporaryMessage(String message) {
    // This could be implemented with a success message state
    // For now, we'll just log it
    debugPrint(message);

    // You could add a success message state here
    // and show it in the UI temporarily
  }

  /// Update FCM token (called by FCM service)
  void updateFcmToken(String token) {
    _fcmToken = token;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get token display format (truncated)
  String get fcmTokenTruncated {
    if (_fcmToken == null) return 'No token';

    if (_fcmToken!.length > 40) {
      return '${_fcmToken!.substring(0, 20)}...${_fcmToken!.substring(_fcmToken!.length - 20)}';
    }

    return _fcmToken!;
  }

  /// Check if FCM is properly configured
  bool get isFcmConfigured => _fcmToken != null && _fcmToken!.isNotEmpty;
}
