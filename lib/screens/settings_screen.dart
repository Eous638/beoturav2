import 'dart:convert';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart'; // Import without alias
import '../enums/language_enum.dart';
import '../l10n/localization_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Comment out notification and privacy settings
  // bool _pushNotifications = true;
  // bool _emailNotifications = false;
  // bool _locationServices = true;
  // bool _dataCollection = true;

  @override
  void initState() {
    super.initState();
    // _loadSettings(); // Simplified as we're not using these settings now
  }

  // Simplified settings management
  Future<void> _saveSettings() async {
    // No-op for now - theme settings handled by provider
  }

  Future<void> updateLanguage(Language language) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language.toString());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = LocalizationHelper(ref);
    final user = ref.watch(authProvider);
    final currentThemeMode = ref.watch(themeProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings header with monochrome style
            Container(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color:
                            isDarkMode ? Colors.white : const Color(0xFF141414),
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.translate('settings'),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? Colors.white
                              : const Color(0xFF141414),
                          fontFamily: 'Domine', // Use Domine for headings
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (user != null)
                    Text(
                      '${l10n.translate('welcome')}, ${user.username}!',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.8)
                            : const Color(0xFF141414).withOpacity(0.8),
                        fontFamily:
                            'Playfair Display', // Use Playfair Display for body
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account section
            _buildSettingsSection(
              l10n.translate('account'),
              Icons.person,
              [
                user == null ? _buildLoginForm() : _buildUserInfo(user),
              ],
            ),

            // Language Settings
            _buildSettingsSection(
              l10n.translate('language_settings'),
              Icons.language,
              [
                RadioListTile<Language>(
                  title: Text(l10n.translate('english')),
                  subtitle: const Text('English'),
                  secondary: const CircleAvatar(
                    backgroundImage: AssetImage('images/uk_flag.png'),
                    radius: 16,
                  ),
                  value: Language.english,
                  groupValue: ref.watch(languageProvider),
                  onChanged: (value) {
                    ref
                        .read(languageProvider.notifier)
                        .update((state) => Language.english);
                    updateLanguage(Language.english);
                  },
                ),
                RadioListTile<Language>(
                  title: Text(l10n.translate('serbian')),
                  subtitle: const Text('Srpski'),
                  secondary: const CircleAvatar(
                    backgroundImage: AssetImage('images/serbia_flag.png'),
                    radius: 16,
                  ),
                  value: Language.serbian,
                  groupValue: ref.watch(languageProvider),
                  onChanged: (value) {
                    ref
                        .read(languageProvider.notifier)
                        .update((state) => Language.serbian);
                    updateLanguage(Language.serbian);
                  },
                ),
              ],
            ),

            // Appearance Settings - Updated to use the theme provider correctly
            _buildSettingsSection(
              l10n.translate('appearance'),
              Icons.palette,
              [
                RadioListTile<ThemeMode>(
                  title: Text(l10n.translate('dark_mode')),
                  value: ThemeMode.dark,
                  groupValue: currentThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.translate('light_mode')),
                  value: ThemeMode.light,
                  groupValue: currentThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(ThemeMode.light);
                    }
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: Text(l10n.translate('system_default')),
                  value: ThemeMode.system,
                  groupValue: currentThemeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(ThemeMode.system);
                    }
                  },
                ),
              ],
            ),

            // Notifications section commented out
            /* 
            _buildSettingsSection(
              l10n.translate('notifications'),
              Icons.notifications,
              [
                SwitchListTile(
                  title: Text(l10n.translate('push_notifications')),
                  subtitle: Text(l10n.translate('receive_push_notifications')),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                      _saveSettings();
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.translate('email_notifications')),
                  subtitle: Text(l10n.translate('receive_email_updates')),
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                      _saveSettings();
                    });
                  },
                ),
              ],
            ),
            */

            // Privacy section commented out
            /*
            _buildSettingsSection(
              l10n.translate('privacy'),
              Icons.privacy_tip,
              [
                SwitchListTile(
                  title: Text(l10n.translate('location_services')),
                  subtitle: Text(l10n.translate('enable_location_services')),
                  value: _locationServices,
                  onChanged: (value) {
                    setState(() {
                      _locationServices = value;
                      _saveSettings();
                    });
                  },
                ),
                SwitchListTile(
                  title: Text(l10n.translate('data_collection')),
                  subtitle: Text(l10n.translate('help_improve')),
                  value: _dataCollection,
                  onChanged: (value) {
                    setState(() {
                      _dataCollection = value;
                      _saveSettings();
                    });
                  },
                ),
              ],
            ),
            */

            // About App
            _buildSettingsSection(
              l10n.translate('about_app'),
              Icons.info,
              [
                ListTile(
                  title: Text(l10n.translate('version')),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  title: Text(l10n.translate('terms')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to terms
                  },
                ),
                ListTile(
                  title: Text(l10n.translate('privacy_policy')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
      String title, IconData icon, List<Widget> children) {
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(icon,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Domine', // Use Domine for headings
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final l10n = LocalizationHelper(ref);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: l10n.translate('username'),
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.translate('password'),
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.login),
            label: Text(l10n.translate('login')),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(User user) {
    final l10n = LocalizationHelper(ref);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[800],
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Domine', // Use Domine for headings
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'user@example.com', // Placeholder for email
            style: TextStyle(
              color: Colors.grey.shade600,
              fontFamily: 'Playfair Display', // Use Playfair Display for body
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: Text(l10n.translate('logout')),
          ),
        ],
      ),
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
            _errorMessage = LocalizationHelper(ref).translate('login_error');
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = LocalizationHelper(ref).translate('network_error');
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
