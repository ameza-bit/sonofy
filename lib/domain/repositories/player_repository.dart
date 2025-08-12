abstract class PlayerRepository {
  bool isPlaying();
  Future<bool> play(String url);
  Future<bool> pause();
  Future<bool> togglePlayPause();
  Future<void> seek(Duration position);
  Future<Duration?> getCurrentPosition();
  Future<Duration?> getDuration();
}
