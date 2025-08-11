import 'package:audioplayers/audioplayers.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';

final class PlayerRepositoryImpl implements PlayerRepository {
  final player = AudioPlayer();

  @override
  Future<void> play(String url) {
    // TODO(Armando): implement play
    throw UnimplementedError();
  }

  @override
  Future<void> pause() {
    // TODO(Armando): implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO(Armando): implement stop
    throw UnimplementedError();
  }

  @override
  Future<void> seek(Duration position) {
    // TODO(Armando): implement seek
    throw UnimplementedError();
  }

  @override
  Future<Duration> getCurrentPosition() {
    // TODO(Armando): implement getCurrentPosition
    throw UnimplementedError();
  }

  @override
  Future<Duration> getDuration() {
    // TODO(Armando): implement getDuration
    throw UnimplementedError();
  }
}
