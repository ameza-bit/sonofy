import 'package:sonofy/data/models/equalizer_model.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';

abstract class EqualizerRepository {
  Future<EqualizerModel> getEqualizerSettings();
  Future<void> saveEqualizerSettings(EqualizerModel equalizer);
  Future<void> setEqualizerEnabled(bool enabled);
  Future<void> setPreset(EqualizerPreset preset);
  Future<void> updateCustomValues(List<double> values);
  Future<void> setPreamp(double preamp);
  Future<void> resetToDefault();
}