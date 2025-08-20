import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  final _api = ApiClient();

  Future<bool> login(String email, String password) async {
    final res = await _api.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    final token = (res.data as Map)['token'];
    if (token == null) return false;
    final sp = await SharedPreferences.getInstance();
    await sp.setString('token', token);
    return true;
  }

  Future<Map?> me() async {
    final res = await _api.get('/auth/me');
    return res.data as Map?;
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove('token');
  }
}
