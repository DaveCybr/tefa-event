import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Initialize
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(_keyToken, token);
    await _prefs?.setBool(_keyIsLoggedIn, true);
  }

  static String? getToken() {
    return _prefs?.getString(_keyToken);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.setBool(_keyIsLoggedIn, false);
  }

  // User Data
  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _prefs?.setString(_keyUser, userJson);
  }

  static UserModel? getUser() {
    final userJson = _prefs?.getString(_keyUser);
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  static Future<void> removeUser() async {
    await _prefs?.remove(_keyUser);
  }

  // FCM Token
  static Future<void> saveFcmToken(String token) async {
    await _prefs?.setString(_keyFcmToken, token);
  }

  static String? getFcmToken() {
    return _prefs?.getString(_keyFcmToken);
  }

  static Future<void> removeFcmToken() async {
    await _prefs?.remove(_keyFcmToken);
  }

  // Notifications Settings
  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  static bool getNotificationsEnabled() {
    return _prefs?.getBool(_keyNotificationsEnabled) ??
        true; // Default: enabled
  }

  // Login Status
  static bool isLoggedIn() {
    return _prefs?.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear All Data (Logout)
  static Future<void> clearAll() async {
    await removeToken();
    await removeUser();
    await removeFcmToken();
    // Keep notification preference
  }

  // Device ID (optional - for FCM)
  static Future<void> saveDeviceId(String deviceId) async {
    await _prefs?.setString('device_id', deviceId);
  }

  static String? getDeviceId() {
    return _prefs?.getString('device_id');
  }
}
