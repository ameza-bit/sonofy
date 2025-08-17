import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/data/models/equalizer_settings.dart';
import 'package:sonofy/domain/repositories/equalizer_repository.dart';

class EqualizerRepositoryImpl implements EqualizerRepository {
  static const String _equalizerKey = 'equalizer_settings';
  EqualizerSettings? _cachedSettings;

  @override
  EqualizerSettings getEqualizerSettings() {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final settingsJson = Preferences.pref.getString(_equalizerKey);
    if (settingsJson != null && settingsJson.isNotEmpty) {
      try {
        _cachedSettings = equalizerSettingsFromJson(settingsJson);
        return _cachedSettings!;
      } catch (e) {
        // Si hay error al deserializar, usar configuración inicial
      }
    }

    _cachedSettings = EqualizerSettings.initial();
    return _cachedSettings!;
  }

  @override
  Future<void> saveEqualizerSettings(EqualizerSettings settings) async {
    _cachedSettings = settings;
    final settingsJson = equalizerSettingsToJson(settings);
    await Preferences.pref.setString(_equalizerKey, settingsJson);
  }

  @override
  Future<bool> setBand(int bandIndex, double gain) async {
    try {
      final currentSettings = getEqualizerSettings();
      final newSettings = currentSettings.updateBand(bandIndex, gain);
      await saveEqualizerSettings(newSettings);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setPreset(EqualizerPreset preset) async {
    try {
      final currentSettings = getEqualizerSettings();
      final newSettings = currentSettings.applyPreset(preset);
      await saveEqualizerSettings(newSettings);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setEnabled(bool enabled) async {
    try {
      final currentSettings = getEqualizerSettings();
      final newSettings = currentSettings.copyWith(isEnabled: enabled);
      await saveEqualizerSettings(newSettings);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  List<double> getBands() {
    return getEqualizerSettings().gains;
  }

  @override
  EqualizerPreset getCurrentPreset() {
    return getEqualizerSettings().currentPreset;
  }

  @override
  bool isEnabled() {
    return getEqualizerSettings().isEnabled;
  }
}
