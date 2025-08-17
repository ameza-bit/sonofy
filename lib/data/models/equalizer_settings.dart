import 'dart:convert';

import 'package:sonofy/core/enums/equalizer_preset.dart';
import 'package:sonofy/data/models/equalizer_band.dart';

EqualizerSettings equalizerSettingsFromJson(String str) =>
    EqualizerSettings.fromJson(json.decode(str));
String equalizerSettingsToJson(EqualizerSettings data) =>
    json.encode(data.toJson());

class EqualizerSettings {
  final List<EqualizerBand> bands;
  final EqualizerPreset currentPreset;
  final bool isEnabled;

  const EqualizerSettings({
    required this.bands,
    this.currentPreset = EqualizerPreset.normal,
    this.isEnabled = false,
  });

  factory EqualizerSettings.initial() {
    return const EqualizerSettings(
      bands: [
        EqualizerBand(name: 'Bass', frequency: '60-250Hz', gain: 0.0),
        EqualizerBand(name: 'Mid', frequency: '250Hz-4kHz', gain: 0.0),
        EqualizerBand(name: 'Treble', frequency: '4-16kHz', gain: 0.0),
      ],
    );
  }

  EqualizerSettings copyWith({
    List<EqualizerBand>? bands,
    EqualizerPreset? currentPreset,
    bool? isEnabled,
  }) {
    return EqualizerSettings(
      bands: bands ?? this.bands,
      currentPreset: currentPreset ?? this.currentPreset,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  EqualizerSettings updateBand(int index, double gain) {
    if (index < 0 || index >= bands.length) return this;

    final newBands = List<EqualizerBand>.from(bands);
    newBands[index] = bands[index].copyWith(gain: gain);

    return copyWith(bands: newBands, currentPreset: EqualizerPreset.custom);
  }

  EqualizerSettings applyPreset(EqualizerPreset preset) {
    final presetGains = preset.defaultBands;
    final newBands = <EqualizerBand>[];

    for (int i = 0; i < bands.length && i < presetGains.length; i++) {
      newBands.add(bands[i].copyWith(gain: presetGains[i]));
    }

    return copyWith(bands: newBands, currentPreset: preset);
  }

  Map<String, dynamic> toJson() => {
    'bands': bands.map((band) => band.toJson()).toList(),
    'currentPreset': currentPreset.index,
    'isEnabled': isEnabled,
  };

  factory EqualizerSettings.fromJson(Map<String, dynamic> json) {
    final bandsJson = json['bands'] as List<dynamic>? ?? [];
    final bands = bandsJson
        .map(
          (bandJson) =>
              EqualizerBand.fromJson(bandJson as Map<String, dynamic>),
        )
        .toList();

    return EqualizerSettings(
      bands: bands.isNotEmpty ? bands : EqualizerSettings.initial().bands,
      currentPreset: EqualizerPreset.values[json['currentPreset'] ?? 0],
      isEnabled: json['isEnabled'] ?? false,
    );
  }

  bool get isCustom => currentPreset == EqualizerPreset.custom;

  List<double> get gains => bands.map((band) => band.gain).toList();
}
