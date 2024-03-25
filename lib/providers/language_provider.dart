import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/language_enum.dart';

final languageProvider = StateProvider<Language>((ref) => Language.english);
