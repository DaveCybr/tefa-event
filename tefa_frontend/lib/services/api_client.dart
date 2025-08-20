import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/event_model.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.5:8000/api';

  // Headers
  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Auth Endpoints
  static Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<UserModel> getMe(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: _getHeaders(token: token),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return UserModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get user data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Event Endpoints
  static Future<EventsResponse> getEvents({
    String? search,
    int page = 1,
    int perPage = 10,
    String? token,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse(
        '$baseUrl/events',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _getHeaders(token: token));

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return EventsResponse.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Failed to get events');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<EventModel> getEventDetail({
    required int eventId,
    String? token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: _getHeaders(token: token),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return EventModel.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get event detail');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> createOrder({
    required int eventId,
    String? notes,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'event_id': eventId,
          if (notes != null) 'notes': notes,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // FCM Token Endpoints
  static Future<Map<String, dynamic>> storeFcmToken({
    required String token,
    required String fcmToken,
    String deviceType = 'android',
    String? deviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/me/fcm-token'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'token': fcmToken,
          'device_type': deviceType,
          if (deviceId != null) 'device_id': deviceId,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to store FCM token');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> refreshFcmToken({
    required String token,
    required String oldToken,
    required String newToken,
    String deviceType = 'android',
    String? deviceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/me/fcm-token/refresh'),
        headers: _getHeaders(token: token),
        body: jsonEncode({
          'old_token': oldToken,
          'new_token': newToken,
          'device_type': deviceType,
          if (deviceId != null) 'device_id': deviceId,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to refresh FCM token');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
