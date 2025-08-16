import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/core/utils/ipod_library_converter.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();

  @override
  bool isPlaying() => player.state == PlayerState.playing;

  @override
  Future<bool> play(String url) async {
    await player.stop();

    String? playableUrl = url;

    if (IpodLibraryConverter.isIpodLibraryUrl(url)) {
      playableUrl = await IpodLibraryConverter.convertIpodUrlToFile(url);
      if (playableUrl == null) {
        return false;
      }
    }

    await player.play(DeviceFileSource(playableUrl));
    return isPlaying();
  }

  @override
  Future<bool> pause() async {
    await player.pause();
    return isPlaying();
  }

  @override
  Future<bool> togglePlayPause() async {
    if (isPlaying()) {
      await player.pause();
    } else {
      await player.resume();
    }
    return isPlaying();
  }

  @override
  Future<bool> seek(Duration position) async {
    await player.seek(position);
    await player.resume();
    return isPlaying();
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    return player.getCurrentPosition();
  }
}
