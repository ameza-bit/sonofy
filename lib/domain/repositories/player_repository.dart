abstract class PlayerRepository {
  Future<bool> play(String url);
  Future<bool> pause();
  Future<bool> stop();
  Future<void> seek(Duration position);
  Future<bool> togglePlayPause();
  bool isPlaying();
  Future<Duration?> getCurrentPosition();
  Future<Duration?> getDuration();
}
