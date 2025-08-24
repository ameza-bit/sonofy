import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonofy/data/models/equalizer_model.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/domain/repositories/equalizer_repository.dart';

class EqualizerRepositoryImpl implements EqualizerRepository {
  static const String _equalizerKey = 'equalizer_settings';

  @override
  Future<EqualizerModel> getEqualizerSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_equalizerKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return EqualizerModel.fromJson(json);
      }

      return const EqualizerModel();
    } catch (e) {
      return const EqualizerModel();
    }
  }

  @override
  Future<void> saveEqualizerSettings(EqualizerModel equalizer) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(equalizer.toJson());
      await prefs.setString(_equalizerKey, jsonString);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Future<void> setEqualizerEnabled(bool enabled) async {
    final current = await getEqualizerSettings();
    final updated = current.copyWith(isEnabled: enabled);
    await saveEqualizerSettings(updated);
  }

  @override
  Future<void> setPreset(EqualizerPreset preset) async {
    final current = await getEqualizerSettings();
    final updated = current.copyWith(currentPreset: preset);
    await saveEqualizerSettings(updated);
  }

  @override
  Future<void> updateCustomValues(List<double> values) async {
    final current = await getEqualizerSettings();
    final updated = current.copyWith(
      customValues: values,
      currentPreset: EqualizerPreset.custom,
    );
    await saveEqualizerSettings(updated);
  }

  @override
  Future<void> setPreamp(double preamp) async {
    final current = await getEqualizerSettings();
    final updated = current.copyWith(preamp: preamp);
    await saveEqualizerSettings(updated);
  }

  @override
  Future<void> resetToDefault() async {
    const defaultSettings = EqualizerModel();
    await saveEqualizerSettings(defaultSettings);
  }
}