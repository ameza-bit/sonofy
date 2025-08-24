enum EqualizerPreset {
  flat('Flat'),
  rock('Rock'),
  pop('Pop'),
  jazz('Jazz'),
  classical('Classical'),
  electronic('Electronic'),
  latin('Latin'),
  vocal('Vocal'),
  bass('Bass Boost'),
  treble('Treble Boost'),
  custom('Custom');

  const EqualizerPreset(this.name);

  final String name;

  static const List<String> frequencyLabels = [
    '60Hz',
    '170Hz',
    '310Hz',
    '600Hz',
    '1kHz',
    '3kHz',
    '6kHz',
    '12kHz',
    '14kHz',
    '16kHz'
  ];

  List<double> get defaultValues {
    switch (this) {
      case EqualizerPreset.flat:
        return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
      case EqualizerPreset.rock:
        return [4.0, 3.0, -2.0, -3.0, -1.0, 2.0, 4.0, 5.0, 5.0, 5.0];
      case EqualizerPreset.pop:
        return [-1.0, 2.0, 3.5, 4.0, 2.5, -1.0, -1.5, -1.5, -1.0, -1.0];
      case EqualizerPreset.jazz:
        return [2.0, 1.0, 0.0, 1.0, -1.5, -1.5, 0.0, 1.0, 2.0, 3.0];
      case EqualizerPreset.classical:
        return [3.0, 2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 2.0, 3.0];
      case EqualizerPreset.electronic:
        return [3.0, 2.0, 0.0, -1.0, -2.0, 1.0, 0.0, 1.0, 3.0, 4.0];
      case EqualizerPreset.latin:
        return [4.0, 2.0, 0.0, 0.0, -1.5, -1.5, -1.5, 0.0, 2.0, 4.0];
      case EqualizerPreset.vocal:
        return [-1.0, 1.0, 2.0, 3.0, 2.0, 1.0, 0.0, -1.0, -2.0, -2.0];
      case EqualizerPreset.bass:
        return [5.0, 4.0, 3.0, 2.0, 1.0, -1.0, -2.0, -2.0, -2.0, -2.0];
      case EqualizerPreset.treble:
        return [-2.0, -2.0, -2.0, -2.0, -1.0, 1.0, 2.0, 3.0, 4.0, 5.0];
      case EqualizerPreset.custom:
        return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }
  }
}