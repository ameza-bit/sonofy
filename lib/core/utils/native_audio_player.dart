import 'dart:io';
import 'package:flutter/services.dart';

class NativeAudioPlayer {
  static const MethodChannel _channel = MethodChannel('native_audio_player');

  static bool get _isAndroid => Platform.isAndroid;

  /// Reproduce un archivo de audio usando el reproductor nativo de Android
  static Future<bool> playTrack(String url) async {
    if (!_isAndroid) {
      return false;
    }

    try {
      final result = await _channel.invokeMethod('playTrack', {
        'url': url,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Pausa la reproducción actual
  static Future<bool> pauseTrack() async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('pauseTrack');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Reanuda la reproducción
  static Future<bool> resumeTrack() async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('resumeTrack');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Detiene la reproducción
  static Future<bool> stopTrack() async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('stopTrack');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Busca a una posición específica en segundos
  static Future<bool> seekToPosition(Duration position) async {
    if (!_isAndroid) return false;

    try {
      final positionSeconds = position.inMilliseconds / 1000.0;
      final result = await _channel.invokeMethod('seekToPosition', {
        'position': positionSeconds,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la posición actual de reproducción
  static Future<Duration> getCurrentPosition() async {
    if (!_isAndroid) return Duration.zero;

    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      final seconds = result as double? ?? 0.0;
      return Duration(milliseconds: (seconds * 1000).round());
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Obtiene la duración total del archivo
  static Future<Duration> getDuration() async {
    if (!_isAndroid) return Duration.zero;

    try {
      final result = await _channel.invokeMethod('getDuration');
      final seconds = result as double? ?? 0.0;
      return Duration(milliseconds: (seconds * 1000).round());
    } catch (e) {
      return Duration.zero;
    }
  }

  /// Verifica si está reproduciendo
  static Future<bool> isPlaying() async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('isPlaying');
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Establece la velocidad de reproducción
  static Future<bool> setPlaybackSpeed(double speed) async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('setPlaybackSpeed', {
        'speed': speed,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Establece el volumen
  static Future<bool> setVolume(double volume) async {
    if (!_isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('setVolume', {
        'volume': volume,
      });
      return result as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el volumen actual
  static Future<double> getVolume() async {
    if (!_isAndroid) return 1.0;

    try {
      final result = await _channel.invokeMethod('getVolume');
      return result as double? ?? 1.0;
    } catch (e) {
      return 1.0;
    }
  }

  /// Verifica si una ruta es un archivo de audio local
  static bool isLocalAudioFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    const supportedExtensions = ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg'];
    return supportedExtensions.contains(extension);
  }
}