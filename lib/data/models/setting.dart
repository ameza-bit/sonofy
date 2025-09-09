import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sonofy/core/enums/language.dart';
import 'package:sonofy/core/enums/order_by.dart';
import 'package:sonofy/data/models/equalizer_settings.dart';

Settings settingsFromJson(String str) => Settings.fromJson(json.decode(str));
String settingsToJson(Settings data) => json.encode(data.toJson());

class Settings {
  final ThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;
  final bool hideControls;
  final Language language;
  final bool biometricEnabled;
  final OrderBy orderBy;
  final double playbackSpeed;
  final EqualizerSettings equalizerSettings;

  Settings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = const Color(0xFF5C42FF),
    this.fontSize = 1.0,
    this.hideControls = false,
    this.language = Language.spanish,
    this.biometricEnabled = false,
    this.orderBy = OrderBy.titleAsc,
    this.playbackSpeed = 1.0,
    EqualizerSettings? equalizerSettings,
  }) : equalizerSettings = equalizerSettings ?? EqualizerSettings.initial();

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    themeMode: ThemeMode.values[json['isDarkMode'] ?? 0],
    primaryColor: Color(json['primaryColor'] ?? 0xFF5C42FF),
    fontSize: (json['fontSize'] ?? 1.0).toDouble(),
    hideControls: json['hideControls'] ?? false,
    language: Language.values[json['language'] ?? 0],
    biometricEnabled: json['biometricEnabled'] ?? false,
    orderBy: OrderByExtension.fromString(json['orderBy'] ?? 'titleAsc'),
    playbackSpeed: (json['playbackSpeed'] ?? 1.0).toDouble(),
    equalizerSettings: json['equalizerSettings'] != null
        ? EqualizerSettings.fromJson(json['equalizerSettings'])
        : EqualizerSettings.initial(),
  );

  Map<String, dynamic> toJson() => {
    'isDarkMode': themeMode.index,
    'primaryColor': primaryColor.toARGB32(),
    'fontSize': fontSize,
    'hideControls': hideControls,
    'language': language.index,
    'biometricEnabled': biometricEnabled,
    'orderBy': orderBy.stringValue,
    'playbackSpeed': playbackSpeed,
    'equalizerSettings': equalizerSettings.toJson(),
  };

  Settings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
    bool? hideControls,
    Language? language,
    bool? biometricEnabled,
    String? localMusicPath,
    OrderBy? orderBy,
    double? playbackSpeed,
    EqualizerSettings? equalizerSettings,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
      hideControls: hideControls ?? this.hideControls,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      orderBy: orderBy ?? this.orderBy,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      equalizerSettings: equalizerSettings ?? this.equalizerSettings,
    );
  }
}
