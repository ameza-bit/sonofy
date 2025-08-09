import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/data/models/setting.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  @override
  Settings getSettings() => Preferences.settings;

  @override
  void saveSettings(Settings settings) => Preferences.settings = settings;
}
