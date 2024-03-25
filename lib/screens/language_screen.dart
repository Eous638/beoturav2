import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';
import '../enums/language_enum.dart';
import '../l10n/localization_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  Future<void> updateLanguage(Language language) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language.toString());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = LocalizationHelper(ref);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('lang_screen')),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CheckboxListTile(
                title: Text(l10n.translate('english')),
                value: ref.watch(languageProvider) == Language.english
                    ? true
                    : false,
                onChanged: (value) {
                  ref
                      .read(languageProvider.notifier)
                      .update((state) => Language.english);
                  updateLanguage(Language.english);
                },
              ),
              CheckboxListTile(
                title: Text(l10n.translate('serbian')),
                value: ref.watch(languageProvider) == Language.serbian
                    ? true
                    : false,
                onChanged: (value) {
                  ref
                      .read(languageProvider.notifier)
                      .update((state) => Language.serbian);
                  updateLanguage(Language.serbian);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
