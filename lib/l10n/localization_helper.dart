import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

// Assuming your Language enum is available globally
import '../enums/language_enum.dart';

class LocalizationHelper {
  // Constructor to make this easy to use with WidgetRef
  LocalizationHelper(this.ref);
  final WidgetRef ref;

  String translate(String key) {
    final currentLanguage = ref.read(languageProvider);

    switch (currentLanguage) {
      case Language.english:
        return _englishTranslations[key] ?? key; // Return English if available
      case Language.serbian:
        return _serbianTranslations[key] ?? key; // Return Serbian if available
      default:
        return key; // Fallback to the key itself
    }
  }

  // Example translations (Replace with your actual data)
  final _englishTranslations = {
    'lang_screen': 'Language Screen',
    'english': 'English',
    'serbian': 'Serbian', // Add Serbian translation for 'Serbian
    'language': 'Language',
    'Tours': 'Tours',
    'home': 'Home',
    'locations': 'Locations',
    'about us': 'About Us',
    'begin tour': 'Begin Tour',
    "our_story": "This is our story",
    'about_text':
        'We are high school students from Belgrade and we are discovering an interesting side of Belgrade history. We explore and photograph the hidden treasures of our city, which you can now experience for yourself! Choose your tour and indulge in the Belgrade Adventure with us! If you want to know more, visit our website.',
    'visit us': 'Visit us',
    'navigation': 'Navigation',
    'begin journey': 'Begin Your Journey' // Add 'navigation' translation
    // Add 'visit us' translation
  };

  final _serbianTranslations = {
    'lang_screen': 'Jezici',
    'english': 'Engleski',
    'serbian': 'Srpski',
    'language': 'Jezik',
    'Tours': 'Ture',
    'home': 'Početna',
    'locations': 'Lokacije',
    'about us': 'O nama',
    'begin tour': 'Započni Turu',
    "our_story": "Ovo je naša priča",
    'about_text':
        'Mi smo srednjoškolci iz Beograda i otkrivamo zanimljivu stranu istorije Beograda. Istražujemo i fotografišemo skrivene dragulje našeg grada, koje sada možete doživeti i sami! Izaberite svoju turu i prepustite se Beogradskoj Avanturi sa nama! Ako želite da saznate više, posetite naš sajt.', // Fix typo 'abut us' to 'O nama
    'visit us': 'Posetite nas', // Add 'visit us' translation
    'navigation': 'Navigacija',
    'begin journey': 'Započnite Vaše Putovanje' // Add 'navigation' translation
  };
}
