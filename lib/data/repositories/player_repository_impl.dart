import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;

  @override
  bool isPlaying() {
    if (_usingNativePlayer) {
      return true; // Native player is async, assume playing when active
    }
    return player.state == PlayerState.playing;
  }

  @override
  Future<bool> play(String url) async {
    await player.stop();
    await IpodLibraryConverter.stopNativeMusicPlayer();
    _usingNativePlayer = false;

    if (IpodLibraryConverter.isIpodLibraryUrl(url)) {
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
      // Use audioplayers for regular files
      await player.play(DeviceFileSource(url));
      return isPlaying();
    }
  }

  @override
  Future<bool> pause() async {
    if (_usingNativePlayer) {
      await IpodLibraryConverter.pauseNativeMusicPlayer();
      return false;
    } else {
      await player.pause();
    }
    return isPlaying();
  }

  @override
  Future<bool> togglePlayPause() async {
    if (_usingNativePlayer) {
      final status = await IpodLibraryConverter.getNativeMusicPlayerStatus();
      if (status == 'playing') {
        await IpodLibraryConverter.pauseNativeMusicPlayer();
        return false;
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
    if (_usingNativePlayer) {
      // Native player doesn't support seek for now
      return isPlaying();
    } else {
      await player.seek(position);
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    if (_usingNativePlayer) {
      // Native player doesn't support position for now
      return Duration.zero;
    } else {
      return player.getCurrentPosition();
    }
  }
}
