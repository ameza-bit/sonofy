import 'package:audioplayers/audioplayers.dart';
import 'package:just_audio/just_audio.dart' as ja;
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();
  final ja.AudioPlayer justAudioPlayer = ja.AudioPlayer();
  bool _usingNativePlayer = false;

  @override
  bool isPlaying() {
    if (_usingNativePlayer) {
      // For native player, we'll check status asynchronously
      return true; // Assume playing if using native player
    }
    return player.state == PlayerState.playing || justAudioPlayer.playing;
  }

  @override
  Future<bool> play(String url) async {
    await player.stop();
    await justAudioPlayer.stop();
    await IpodLibraryConverter.stopNativeMusicPlayer();
    _usingNativePlayer = false;

    if (IpodLibraryConverter.isIpodLibraryUrl(url)) {
      print('🎵 Checking iPod Library URL: $url');
      
      // First check if the song is DRM protected
      bool isDrmProtected = await IpodLibraryConverter.isDrmProtected(url);
      print('🔒 DRM Status: ${isDrmProtected ? "Protected" : "Not Protected"}');
      
      if (isDrmProtected) {
        print('❌ Cannot play DRM protected content');
        return false;
      }
      
      // Try native iOS music player first (best for iPod library)
      print('🎵 Trying native iOS music player...');
      bool nativeSuccess = await IpodLibraryConverter.playWithNativeMusicPlayer(url);
      
      if (nativeSuccess) {
        _usingNativePlayer = true;
        print('✅ Playing with native iOS music player');
        return true;
      }
      
      print('⚠️ Native player failed, trying just_audio...');
      try {
        await justAudioPlayer.setUrl(url);
        await justAudioPlayer.play();
        return justAudioPlayer.playing;
      } catch (e) {
        print('❌ just_audio failed, trying conversion: $e');
        
        String? playableUrl = await IpodLibraryConverter.convertIpodUrlToFile(url);
        print('Converted URL: $playableUrl');
        
        if (playableUrl != null) {
          await player.play(DeviceFileSource(playableUrl));
          return isPlaying();
        }
        
        return false;
      }
    } else {
      await player.play(DeviceFileSource(url));
      return isPlaying();
    }
  }

  @override
  Future<bool> pause() async {
    if (_usingNativePlayer) {
      await IpodLibraryConverter.pauseNativeMusicPlayer();
      return false; // Paused
    } else if (justAudioPlayer.playing) {
      await justAudioPlayer.pause();
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
        // For native player, we can't easily resume, so we return current state
        return status == 'playing';
      }
    } else if (isPlaying()) {
      if (justAudioPlayer.playing) {
        await justAudioPlayer.pause();
      } else {
        await player.pause();
      }
    } else {
      if (justAudioPlayer.processingState != ja.ProcessingState.idle) {
        await justAudioPlayer.play();
      } else {
        await player.resume();
      }
    }
    return isPlaying();
  }

  @override
  Future<bool> seek(Duration position) async {
    if (justAudioPlayer.processingState != ja.ProcessingState.idle) {
      await justAudioPlayer.seek(position);
    } else {
      await player.seek(position);
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    if (justAudioPlayer.processingState != ja.ProcessingState.idle) {
      return justAudioPlayer.position;
    } else {
      return player.getCurrentPosition();
    }
  }
}
