import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  bool _usingNativePlayer = false;
  double _playbackSpeed = 1.0;
  
  // Equalizer state (for future implementation with just_audio or native)
  bool _equalizerEnabled = false;
  List<double> _equalizerBands = List.filled(10, 0.0);
  double _preamp = 0.0;

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
      return IpodLibraryConverter.setPlaybackSpeed(speed);
    } else {
      await player.setPlaybackRate(speed);
      return true;
    }
  }

  @override
  double getPlaybackSpeed() {
    if (_usingNativePlayer && Platform.isIOS) {
      // For native player, we return the stored speed since getPlaybackSpeed is async
      // but this method needs to be sync. The actual speed should be synced when setting.
      return _playbackSpeed;
    }
    return _playbackSpeed;
  }

  @override
  Future<bool> setEqualizerEnabled(bool enabled) async {
    _equalizerEnabled = enabled;
    // TODO: Implement actual equalizer control when migrating to just_audio
    // For now, just store the state
    return true;
  }

  @override
  Future<bool> setEqualizerBand(int bandIndex, double gain) async {
    if (bandIndex < 0 || bandIndex >= 10) return false;
    
    _equalizerBands[bandIndex] = gain.clamp(-12.0, 12.0);
    
    // TODO: Apply equalizer band when using just_audio or native implementation
    // For now, just store the values
    return _equalizerEnabled;
  }

  @override
  Future<bool> setAllEqualizerBands(List<double> gains) async {
    if (gains.length != 10) return false;
    
    for (int i = 0; i < 10; i++) {
      _equalizerBands[i] = gains[i].clamp(-12.0, 12.0);
    }
    
    // TODO: Apply all equalizer bands when using just_audio or native implementation
    return _equalizerEnabled;
  }

  @override
  Future<bool> setEqualizerPreamp(double gain) async {
    _preamp = gain.clamp(-12.0, 12.0);
    
    // TODO: Apply preamp when using just_audio or native implementation
    return _equalizerEnabled;
  }

  @override
  Future<bool> resetEqualizer() async {
    _equalizerEnabled = false;
    _equalizerBands = List.filled(10, 0.0);
    _preamp = 0.0;
    
    // TODO: Reset actual equalizer when using just_audio or native implementation
    return true;
  }
}
