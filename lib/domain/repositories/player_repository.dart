abstract class PlayerRepository {
  Future<void> play(String url);
  Future<void> pause();
  Future<void> stop();
  Future<void> seek(Duration position);
  Future<Duration?> getCurrentPosition();
  Future<Duration?> getDuration();
}
