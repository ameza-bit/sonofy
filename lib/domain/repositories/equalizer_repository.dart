import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/data/models/equalizer_settings.dart';

abstract class EqualizerRepository {
  EqualizerSettings getEqualizerSettings();
  Future<void> saveEqualizerSettings(EqualizerSettings settings);

  Future<bool> setBand(int bandIndex, double gain);
  Future<bool> setPreset(EqualizerPreset preset);
  Future<bool> setEnabled(bool enabled);

  List<double> getBands();
  EqualizerPreset getCurrentPreset();
  bool isEnabled();
}
