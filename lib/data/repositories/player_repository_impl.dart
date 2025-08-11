import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();

  @override
  Future<void> play(String url) async {
    await player.play(UrlSource(url));
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> stop() async {
    await player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  @override
  Future<Duration?> getCurrentPosition() async {
    return player.getCurrentPosition();
  }

  @override
  Future<Duration?> getDuration() async {
    return player.getDuration();
  }
}
