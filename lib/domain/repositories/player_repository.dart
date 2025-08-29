sealed class PlayerEvent {}

class PlayEvent extends PlayerEvent {}

class PauseEvent extends PlayerEvent {}

class NextEvent extends PlayerEvent {}

class PreviousEvent extends PlayerEvent {}

class SeekEvent extends PlayerEvent {
  final Duration position;
  SeekEvent(this.position);
}

abstract class PlayerRepository {
  bool isPlaying();
  Future<bool> playTrack(String url);
  Future<bool> pauseTrack();
  Future<bool> resumeTrack();
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

  Future<bool> setVolume(double volume);
  Future<double> getVolume();

  Stream<PlayerEvent> get playerEvents;
}
