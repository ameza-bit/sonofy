class EqualizerBand {
  final String name;
  final String frequency;
  final double gain;
  final double minGain;
  final double maxGain;

  const EqualizerBand({
    required this.name,
    required this.frequency,
    required this.gain,
    this.minGain = -12.0,
    this.maxGain = 12.0,
  });

  EqualizerBand copyWith({
    String? name,
    String? frequency,
    double? gain,
    double? minGain,
    double? maxGain,
  }) {
    return EqualizerBand(
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      gain: gain ?? this.gain,
      minGain: minGain ?? this.minGain,
      maxGain: maxGain ?? this.maxGain,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'frequency': frequency,
    'gain': gain,
    'minGain': minGain,
    'maxGain': maxGain,
  };

  factory EqualizerBand.fromJson(Map<String, dynamic> json) => EqualizerBand(
    name: json['name'] ?? '',
    frequency: json['frequency'] ?? '',
    gain: (json['gain'] ?? 0.0).toDouble(),
    minGain: (json['minGain'] ?? -12.0).toDouble(),
    maxGain: (json['maxGain'] ?? 12.0).toDouble(),
  );
}
