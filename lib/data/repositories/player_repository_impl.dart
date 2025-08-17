import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;
  double _playbackSpeed = 1.0;

  @override
  bool isPlaying() {
    if (_usingNativePlayer && Platform.isIOS) {
      // For native player, we need to check async, but this is sync
      // Return true when using native player - UI should call status check
      return true;
    }
    return player.state == PlayerState.playing;
  }

  @override
  Future<bool> play(String url) async {
    await player.stop();
    await IpodLibraryConverter.stopNativeMusicPlayer();
    _usingNativePlayer = false;

    if (IpodLibraryConverter.isIpodLibraryUrl(url) && Platform.isIOS) {
      // Check if DRM protected
      final isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
      if (isDrmProtected) {
        return false;
      }

      // Use native iOS music player for iPod library URLs
      final success = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
      if (success) {
        _usingNativePlayer = true;
      }
      return success;
    } else {
      // Use audioplayers for regular files (and iPod URLs on Android)
      await player.play(DeviceFileSource(url));
      return isPlaying();
    }
  }

  @override
  Future<bool> pause() async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.pauseNativeMusicPlayer();
      return false;
    } else {
      await player.pause();
    }
    return isPlaying();
  }

  @override
  Future<bool> togglePlayPause() async {
    if (_usingNativePlayer && Platform.isIOS) {
      final status = await IpodLibraryConverter.getNativeMusicPlayerStatus();
      if (status == 'playing') {
        await IpodLibraryConverter.pauseNativeMusicPlayer();
        return false;
      } else if (status == 'paused') {
        await IpodLibraryConverter.resumeNativeMusicPlayer();
        return true;
      } else {
        return status == 'playing';
      }
    } else if (isPlaying()) {
      await player.pause();
    } else {
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<bool> seek(Duration position) async {
    if (_usingNativePlayer && Platform.isIOS) {
      await IpodLibraryConverter.seekToPosition(position);
      await IpodLibraryConverter.resumeNativeMusicPlayer();
      return isPlaying();
    } else {
      await player.seek(position);
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.getCurrentPosition();
    } else {
      return player.getCurrentPosition();
    }
  }

  @override
  Future<Duration?> getDuration() async {
    if (_usingNativePlayer && Platform.isIOS) {
      return IpodLibraryConverter.getDuration();
    } else {
      return player.getDuration();
    }
  }

  @override
  Future<bool> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;

    if (_usingNativePlayer && Platform.isIOS) {
      // TODO(Armando): Implement native iOS playback speed control
      // Native iOS player doesn't support speed control via Method Channel yet
      return false;
    } else {
      await player.setPlaybackRate(speed);
      return true;
    }
  }

  @override
  double getPlaybackSpeed() {
    return _playbackSpeed;
  }
}
