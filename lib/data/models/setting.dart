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

  Settings({
    this.themeMode = ThemeMode.system,
    this.primaryColor = const Color(0xFF5C42FF),
    this.fontSize = 1.0,
    this.language = Language.spanish,
    this.biometricEnabled = false,
    this.localMusicPath,
    this.orderBy = OrderBy.titleAsc,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    themeMode: ThemeMode.values[json['isDarkMode'] ?? 0],
    primaryColor: Color(json['primaryColor'] ?? 0xFF5C42FF),
    fontSize: (json['fontSize'] ?? 1.0).toDouble(),
    language: Language.values[json['language'] ?? 0],
    biometricEnabled: json['biometricEnabled'] ?? false,
    localMusicPath: json['localMusicPath'],
    orderBy: OrderByExtension.fromString(json['orderBy'] ?? 'titleAsc'),
  );

  Map<String, dynamic> toJson() => {
    'isDarkMode': themeMode.index,
    'primaryColor': primaryColor.toARGB32(),
    'fontSize': fontSize,
    'language': language.index,
    'biometricEnabled': biometricEnabled,
    'localMusicPath': localMusicPath,
    'orderBy': orderBy.stringValue,
  };

  Settings copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
    Language? language,
    bool? biometricEnabled,
    String? localMusicPath,
    OrderBy? orderBy,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      localMusicPath: localMusicPath ?? this.localMusicPath,
      orderBy: orderBy ?? this.orderBy,
    );
  }
}
