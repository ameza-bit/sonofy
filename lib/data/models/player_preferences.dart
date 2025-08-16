import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

PlayerPreferences playerPreferencesFromJson(String str) => PlayerPreferences.fromJson(json.decode(str));
String playerPreferencesToJson(PlayerPreferences data) => json.encode(data.toJson());

@immutable
class PlayerPreferences {
  final bool isShuffleEnabled;
  final RepeatMode repeatMode;

  const PlayerPreferences({
    this.isShuffleEnabled = false,
    this.repeatMode = RepeatMode.none,
  });

  factory PlayerPreferences.fromJson(Map<String, dynamic> json) => PlayerPreferences(
    isShuffleEnabled: json['isShuffleEnabled'] ?? false,
    repeatMode: RepeatMode.values[json['repeatMode'] ?? 0],
  );

  Map<String, dynamic> toJson() => {
    'isShuffleEnabled': isShuffleEnabled,
    'repeatMode': repeatMode.index,
  };

  PlayerPreferences copyWith({
    bool? isShuffleEnabled,
    RepeatMode? repeatMode,
  }) {
    return PlayerPreferences(
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerPreferences &&
        other.isShuffleEnabled == isShuffleEnabled &&
        other.repeatMode == repeatMode;
  }

  @override
  int get hashCode => Object.hash(isShuffleEnabled, repeatMode);

  @override
  String toString() {
    return 'PlayerPreferences('
        'isShuffleEnabled: $isShuffleEnabled, '
        'repeatMode: $repeatMode'
        ')';
  }
}