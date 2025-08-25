import 'dart:io';
import 'package:flutter/foundation.dart';

enum DevicePlatformType { android, ios, web, macos, windows, linux }

class DevicePlatform {
  static DevicePlatformType get _currentPlatform {
    if (kIsWeb) {
      return DevicePlatformType.web;
    } else if (Platform.isAndroid) {
      return DevicePlatformType.android;
    } else if (Platform.isIOS) {
      return DevicePlatformType.ios;
    } else if (Platform.isMacOS) {
      return DevicePlatformType.macos;
    } else if (Platform.isWindows) {
      return DevicePlatformType.windows;
    } else if (Platform.isLinux) {
      return DevicePlatformType.linux;
    }

    throw Exception('Unknown platform');
  }

  static bool get isWeb => _currentPlatform == DevicePlatformType.web;

  static bool get isAndroid => _currentPlatform == DevicePlatformType.android;

  static bool get isIOS => _currentPlatform == DevicePlatformType.ios;

  static bool get isMacOS => _currentPlatform == DevicePlatformType.macos;

  static bool get isWindows => _currentPlatform == DevicePlatformType.windows;

  static bool get isLinux => _currentPlatform == DevicePlatformType.linux;

  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop => isMacOS || isWindows || isLinux;
}
