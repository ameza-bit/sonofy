import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sonofy/core/enums/language.dart';
import 'package:sonofy/core/enums/order_by.dart';

Settings settingsFromJson(String str) => Settings.fromJson(json.decode(str));
String settingsToJson(Settings data) => json.encode(data.toJson());

class Settings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;
  final Language language;
  final bool biometricEnabled;
  final String? localMusicPath;
  final OrderBy orderBy;
  final double playbackSpeed;

  Settings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = const Color(0xFF5C42FF),
    this.fontSize = 1.0,
    this.language = Language.spanish,
    this.biometricEnabled = false,
    this.localMusicPath,
    this.orderBy = OrderBy.titleAsc,
    this.playbackSpeed = 1.0,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    themeMode: ThemeMode.values[json['isDarkMode'] ?? 0],
    primaryColor: Color(json['primaryColor'] ?? 0xFF5C42FF),
    fontSize: (json['fontSize'] ?? 1.0).toDouble(),
    language: Language.values[json['language'] ?? 0],
    biometricEnabled: json['biometricEnabled'] ?? false,
    localMusicPath: json['localMusicPath'],
    orderBy: OrderByExtension.fromString(json['orderBy'] ?? 'titleAsc'),
    playbackSpeed: (json['playbackSpeed'] ?? 1.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'isDarkMode': themeMode.index,
    'primaryColor': primaryColor.toARGB32(),
    'fontSize': fontSize,
    'language': language.index,
    'biometricEnabled': biometricEnabled,
    'localMusicPath': localMusicPath,
    'orderBy': orderBy.stringValue,
    'playbackSpeed': playbackSpeed,
  };

  Settings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
    Language? language,
    bool? biometricEnabled,
    String? localMusicPath,
    OrderBy? orderBy,
    double? playbackSpeed,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      localMusicPath: localMusicPath ?? this.localMusicPath,
      orderBy: orderBy ?? this.orderBy,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }
}
