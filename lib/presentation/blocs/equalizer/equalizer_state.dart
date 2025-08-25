import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/data/models/equalizer_band.dart';
import 'package:sonofy/data/models/equalizer_settings.dart';

class EqualizerState {
  final EqualizerSettings settings;
  final bool isLoading;
  final String? error;

  const EqualizerState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  factory EqualizerState.initial() {
    return EqualizerState(settings: EqualizerSettings.initial());
  }

  EqualizerState copyWith({
    EqualizerSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return EqualizerState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Getters de conveniencia
  List<EqualizerBand> get bands => settings.bands;
  EqualizerPreset get currentPreset => settings.currentPreset;
  bool get isEnabled => settings.isEnabled;
  bool get isCustom => settings.isCustom;
  List<double> get gains => settings.gains;

  double getBandGain(int index) {
    if (index >= 0 && index < bands.length) {
      return bands[index].gain;
    }
    return 0.0;
  }

  String getBandName(int index) {
    if (index >= 0 && index < bands.length) {
      return bands[index].name;
    }
    return '';
  }

  String getBandFrequency(int index) {
    if (index >= 0 && index < bands.length) {
      return bands[index].frequency;
    }
    return '';
  }
}
