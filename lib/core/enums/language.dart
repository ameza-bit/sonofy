import 'package:easy_localization/easy_localization.dart';

enum Language { spanish, english }

extension LanguageExtension on Language {
  String get name {
    switch (this) {
      case Language.spanish:
        return 'app.language.spanish'.tr();
      case Language.english:
        return 'app.language.english'.tr();
    }
  }

  String get code {
    switch (this) {
      case Language.spanish:
        return 'es';
      case Language.english:
        return 'en';
    }
  }

  String get flag {
    // Replace with actual logic to determine if in America
    final bool isInAmerica = bool.tryParse('true') ?? false;

    switch (this) {
      case Language.spanish:
        return isInAmerica ? '🇲🇽' : '🇪🇸';
      case Language.english:
        return isInAmerica ? '🇺🇸' : '🇬🇧';
    }
  }
}
