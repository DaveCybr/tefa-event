import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  /// Initialize auth state from storage
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is logged in
      final isLoggedIn = StorageService.isLoggedIn();
      final storedToken = StorageService.getToken();
      final storedUser = StorageService.getUser();

      if (isLoggedIn && storedToken != null && storedUser != null) {
        _token = storedToken;
        _user = storedUser;
        _isAuthenticated = true;

        // Verify token is still valid
        await _verifyToken();
      }
    } catch (e) {
      debugPrint('Auth initialization error: $e');
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify token validity
  Future<void> _verifyToken() async {
    try {
      if (_token == null) return;

      final userData = await ApiService.getMe(_token!);
      _user = userData;
      await StorageService.saveUser(_user!);
    } catch (e) {
      debugPrint('Token verification failed: $e');
      await logout();
    }
  }

  /// Login
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email: email, password: password);

      if (response.success) {
        _token = response.data.token;
        _user = response.data.user;
        _isAuthenticated = true;

        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveUser(_user!);

        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear storage
      await StorageService.clearAll();

      // Reset state
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    if (_token == null) return;

    try {
      final userData = await ApiService.getMe(_token!);
      _user = userData;
      await StorageService.saveUser(_user!);
      notifyListeners();
    } catch (e) {
      debugPrint('Refresh user error: $e');
      // If refresh fails, token might be invalid
      await logout();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return _user?.role == role;
  }

  /// Check if user is organizer
  bool get isOrganizer => hasRole('organizer');

  /// Check if user is participant
  bool get isParticipant => hasRole('participant');
}
