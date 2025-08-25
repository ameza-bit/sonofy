import 'package:sonofy/data/models/setting.dart';

abstract class SettingsRepository {
  Settings getSettings();
  void saveSettings(Settings settings);
}
