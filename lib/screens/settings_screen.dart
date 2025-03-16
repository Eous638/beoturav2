import 'dart:convert';
import 'package:flutter/material.dart'
    hide ThemeMode; // Hide Flutter's ThemeMode to prevent conflicts
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart'; // Import without alias
import '../enums/language_enum.dart';
import '../l10n/localization_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = LocalizationHelper(ref); // Instantiate LocalizationHelper

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('Settings')), // Use the correct instance
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
