enum EqualizerPreset {
  normal,
  rock,
  pop,
  jazz,
  classical,
  custom;

  String get displayName {
    switch (this) {
      case EqualizerPreset.normal:
        return 'Normal';
      case EqualizerPreset.rock:
        return 'Rock';
      case EqualizerPreset.pop:
        return 'Pop';
      case EqualizerPreset.jazz:
        return 'Jazz';
      case EqualizerPreset.classical:
        return 'Classical';
      case EqualizerPreset.custom:
        return 'Custom';
    }
  }

  List<double> get defaultBands {
    switch (this) {
      case EqualizerPreset.normal:
        return [0.0, 0.0, 0.0]; // Bass, Mid, Treble
      case EqualizerPreset.rock:
        return [4.0, 2.0, 6.0];
      case EqualizerPreset.pop:
        return [2.0, 4.0, 3.0];
      case EqualizerPreset.jazz:
        return [3.0, 1.0, 4.0];
      case EqualizerPreset.classical:
        return [1.0, -2.0, 5.0];
      case EqualizerPreset.custom:
        return [0.0, 0.0, 0.0];
    }
  }
}
