import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/localization_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = LocalizationHelper(ref);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 50),
            child: Text(
              l10n.translate('our_story'),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Container(
            height: 220,
            width: 500,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('images/beoturaEkipa.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              l10n.translate('about_text'),
              textAlign: TextAlign.justify,
              style: const TextStyle(
                  fontSize: 15, letterSpacing: 0.5, wordSpacing: 1),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: _launchURL,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            ),
            child: Text(l10n.translate('visit us'),
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
}

void _launchURL() async {
  final Uri url = Uri.parse('https://www.beotura.rs/');
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
