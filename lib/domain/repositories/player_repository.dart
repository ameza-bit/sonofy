abstract class PlayerRepository {
  bool isPlaying();
  Future<bool> playTrack(String url);
  Future<bool> pauseTrack();
  Future<bool> togglePlayPause();
  Future<bool> seekToPosition(Duration position);
  Future<Duration?> getCurrentPosition();
  Future<Duration?> getDuration();

  Future<bool> setPlaybackSpeed(double speed);
  double getPlaybackSpeed();

  Future<bool> setEqualizerBand(int bandIndex, double gain);
  Future<List<double>> getEqualizerBands();
  Future<bool> setEqualizerEnabled(bool enabled);
  Future<bool> isEqualizerEnabled();
}
