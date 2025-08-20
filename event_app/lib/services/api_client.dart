import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._();
  factory ApiClient() => _i;
  ApiClient._();

  // Ganti ke base URL server kamu
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8000',
      ),
    ),
  );

  Future<void> _attachToken() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    dio.options.headers['Accept'] = 'application/json';
    if (token != null) dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? q}) async {
    await _attachToken();
    return dio.get<T>(path, queryParameters: q);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) async {
    await _attachToken();
    return dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) async {
    await _attachToken();
    return dio.put<T>(path, data: data);
  }
}
