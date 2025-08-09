import 'dart:io';
import 'package:samva/data/models/setting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences pref;

  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
    await reload();
  }

  static Future<void> reload() async => pref.reload();

  static Future<void> logOut() async {
    pref.getKeys().forEach((key) async {
      if (!key.contains('ND_')) await deleted(key);
    });
  }

  static Future<void> deleted(String key) async {
    if (pref.containsKey(key)) {
      if (key.contains('IMG_')) {
        final String? path = pref.getString(key);
        try {
          if (path != null) {
            final File file = File(path);
            await file.delete();
          }
        } catch (e) {
          Exception('Delete file: $e');
        }
      }
      await pref.remove(key);
    }
  }

  static Settings get settings {
    final String? settingsString = pref.getString('ND_SETTINGS');
    if (settingsString != null) {
      return settingsFromJson(settingsString);
    } else {
      return Settings();
    }
  }

  static set settings(Settings settings) {
    pref.setString('ND_SETTINGS', settingsToJson(settings));
  }
}
