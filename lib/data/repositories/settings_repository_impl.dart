
import 'package:samva/core/services/preferences.dart';
import 'package:samva/data/models/setting.dart';
import 'package:samva/domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Settings getSettings() => Preferences.settings;

  @override
  void saveSettings(Settings settings) => Preferences.settings = settings;
}
