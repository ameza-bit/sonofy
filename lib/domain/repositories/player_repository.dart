abstract class PlayerRepository {
  bool isPlaying();
  Future<bool> play(String url);
  Future<bool> pause();
  Future<bool> togglePlayPause();
  Future<bool> seek(Duration position);
  Future<Duration?> getCurrentPosition();
}
