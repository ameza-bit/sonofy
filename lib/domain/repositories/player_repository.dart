abstract class PlayerRepository {
  bool isPlaying();
  Future<bool> play(String url);
  Future<bool> pause();
  Future<bool> togglePlayPause();
  Future<bool> seek(Duration position);
  Future<Duration?> getCurrentPosition();
  Future<Duration?> getDuration();

  Future<bool> setPlaybackSpeed(double speed);
  double getPlaybackSpeed();

  Future<bool> setEqualizerBand(int bandIndex, double gain);
  Future<List<double>> getEqualizerBands();
  Future<bool> setEqualizerEnabled(bool enabled);
  Future<bool> isEqualizerEnabled();
}
