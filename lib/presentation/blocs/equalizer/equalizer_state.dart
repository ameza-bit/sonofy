import 'package:flutter/foundation.dart';
import 'package:sonofy/data/models/equalizer_model.dart';

@immutable
class EqualizerState {
  final EqualizerModel equalizer;
  final bool isLoading;
  final String? errorMessage;

  const EqualizerState({
    this.equalizer = const EqualizerModel(),
    this.isLoading = false,
    this.errorMessage,
  });

  EqualizerState copyWith({
    EqualizerModel? equalizer,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EqualizerState(
      equalizer: equalizer ?? this.equalizer,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EqualizerState &&
        other.equalizer == equalizer &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode =>
      equalizer.hashCode ^ isLoading.hashCode ^ errorMessage.hashCode;
}