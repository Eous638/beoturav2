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
    'begin journey': 'Begin Your Journey', // Add 'navigation' translation
    'settings': 'Settings',
    'language_settings': 'Language Settings',
    'account': 'Account',
    'username': 'Username',
    'password': 'Password',
    'login': 'Login',
    'logout': 'Logout',
    'login_error': 'Login failed. Please check your credentials.',
    'network_error': 'Network error. Please try again.',
    'welcome': 'Welcome',
    'appearance': 'Appearance',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'system_default': 'System Default',
    'notifications': 'Notifications',
    'push_notifications': 'Push Notifications',
    'email_notifications': 'Email Notifications',
    'privacy': 'Privacy',
    'data_collection': 'Data Collection',
    'location_services': 'Location Services',
    'about_app': 'About App',
    'version': 'Version',
    'terms': 'Terms of Service',
    'privacy_policy': 'Privacy Policy',
    'welcome_to_beotura': 'Welcome to BeOtura',
    'discover': 'Discover Belgrade',
    'explore_tours_desc': 'Explore curated tours around the city',
    'discover_locations_desc': 'Find interesting places and landmarks',
    'blog': 'Blog',
    'no_blogs_available': 'No blog posts available',
    'error_loading_blogs': 'Error loading blog posts',
    'try_again': 'Try Again',
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
    'begin journey': 'Započnite Vaše Putovanje', // Add 'navigation' translation
    'settings': 'Podešavanja',
    'language_settings': 'Podešavanja jezika',
    'account': 'Nalog',
    'username': 'Korisničko ime',
    'password': 'Lozinka',
    'login': 'Prijavi se',
    'logout': 'Odjavi se',
    'login_error': 'Prijava nije uspela. Proverite kredencijale.',
    'network_error': 'Greška mreže. Molimo pokušajte ponovo.',
    'welcome': 'Dobrodošli',
    'appearance': 'Izgled',
    'dark_mode': 'Tamni režim',
    'light_mode': 'Svetli režim',
    'system_default': 'Sistemski podrazumevano',
    'notifications': 'Obaveštenja',
    'push_notifications': 'Push obaveštenja',
    'email_notifications': 'Email obaveštenja',
    'privacy': 'Privatnost',
    'data_collection': 'Prikupljanje podataka',
    'location_services': 'Usluge lokacije',
    'about_app': 'O aplikaciji',
    'version': 'Verzija',
    'terms': 'Uslovi korišćenja',
    'privacy_policy': 'Politika privatnosti',
    'welcome_to_beotura': 'Dobrodošli u BeOturu',
    'discover': 'Otkrijte Beograd',
    'explore_tours_desc': 'Istražite pripremljene ture po gradu',
    'discover_locations_desc': 'Pronađite zanimljiva mesta i znamenitosti',
    'blog': 'Blog',
    'no_blogs_available': 'Nema dostupnih blog postova',
    'error_loading_blogs': 'Greška pri učitavanju blog postova',
    'try_again': 'Pokušaj ponovo',
  };
}
