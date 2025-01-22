import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

final authProvider =
    StateNotifierProvider<AuthNotifier, User?>((ref) => AuthNotifier());

class User {
  final String username;
  final String token;
  User(this.username, this.token);
}

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null) {
    _loadUserFromPreferences();
    _startPeriodicUserCheck();
  }

  void login(String username, String token) async {
    state = User(username, token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('token', token);
  }

  void logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('token');
  }

  bool get isLoggedIn => state != null;

  Future<void> _loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final token = prefs.getString('token');
    if (username != null && token != null) {
      state = User(username, token);
    }
  }

  void _startPeriodicUserCheck() {
    Timer.periodic(const Duration(seconds: 42), (timer) async {
      if (state != null) {
        try {
          final response = await http.get(
            Uri.parse('https://api2.gladni.rs/api/beotura/users/me'),
            headers: {
              'Authorization': 'Bearer ${state!.token}',
            },
          );

          if (response.statusCode != 200) {
            logout();
          }
        } catch (e) {
          logout();
        }
      }
    });
  }
}
