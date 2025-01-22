import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null ? _buildLoginForm() : _buildUserInfo(user),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        TextField(
          controller: _passwordController,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        if (_isLoading) const CircularProgressIndicator(),
        if (_errorMessage != null)
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          child: const Text('Login'),
        ),
      ],
    );
  }

  Widget _buildUserInfo(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome, ${user.username}!',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _logout,
          child: const Text('Logout'),
        ),
      ],
    );
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await http.post(
          Uri.parse('https://api2.gladni.rs/api/beotura/token'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'username': username, 'password': password},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['access_token'];
          ref.read(authProvider.notifier).login(username, token);
        } else {
          setState(() {
            _errorMessage = 'Incorrect username or password';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
  }
}
