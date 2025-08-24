import 'package:flutter/foundation.dart';
import 'package:sonofy/core/enums/equalizer_preset.dart';

@immutable
class EqualizerModel {
  final bool isEnabled;
  final EqualizerPreset currentPreset;
  final List<double> customValues;
  final double preamp;

  const EqualizerModel({
    this.isEnabled = false,
    this.currentPreset = EqualizerPreset.flat,
    this.customValues = const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    this.preamp = 0.0,
  });

  EqualizerModel copyWith({
    bool? isEnabled,
    EqualizerPreset? currentPreset,
    List<double>? customValues,
    double? preamp,
  }) {
    return EqualizerModel(
      isEnabled: isEnabled ?? this.isEnabled,
      currentPreset: currentPreset ?? this.currentPreset,
      customValues: customValues ?? this.customValues,
      preamp: preamp ?? this.preamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'currentPreset': currentPreset.name,
      'customValues': customValues,
      'preamp': preamp,
    };
  }

  factory EqualizerModel.fromJson(Map<String, dynamic> json) {
    final presetName = json['currentPreset'] ?? 'flat';
    final preset = EqualizerPreset.values.firstWhere(
      (p) => p.name == presetName,
      orElse: () => EqualizerPreset.flat,
    );

    return EqualizerModel(
      isEnabled: json['isEnabled'] ?? false,
      currentPreset: preset,
      customValues: (json['customValues'] as List<dynamic>?)
              ?.map<double>((e) => e.toDouble())
              .toList() ??
          const [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
      preamp: (json['preamp'] ?? 0.0).toDouble(),
    );
  }

  List<double> get currentValues {
    return currentPreset == EqualizerPreset.custom
        ? customValues
        : currentPreset.defaultValues;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EqualizerModel &&
        other.isEnabled == isEnabled &&
        other.currentPreset == currentPreset &&
        _listEquals(other.customValues, customValues) &&
        other.preamp == preamp;
  }

  @override
  int get hashCode {
    return isEnabled.hashCode ^
        currentPreset.hashCode ^
        customValues.hashCode ^
        preamp.hashCode;
  }

  static bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}