import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && ApiService.token != null;
  String get userRole => _user?['role'] ?? '';
  String get userId => _user?['id'] ?? '';
  String get fullName =>
      '${_user?['first_name'] ?? ''} ${_user?['last_name'] ?? ''}'.trim();

  Future<void> init() async {
    await ApiService.init();
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null && ApiService.token != null) {
      _user = jsonDecode(userData);
      // Verify token is still valid
      try {
        final response = await ApiService.get('/accounts/profile/');
        _user = response;
        await prefs.setString('user_data', jsonEncode(response));
      } catch (e) {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/accounts/register/',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'password_confirm': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': role,
        },
      );

      await ApiService.setToken(response['token']);
      _user = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/accounts/login/',
        body: {'username': username, 'password': password},
      );

      await ApiService.setToken(response['token']);
      _user = response['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/accounts/logout/');
    } catch (_) {}
    await ApiService.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      final response = await ApiService.get('/accounts/profile/');
      _user = response;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user));
      notifyListeners();
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
