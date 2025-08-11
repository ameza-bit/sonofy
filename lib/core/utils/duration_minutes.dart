class DurationMinutes {
  static String format(int durationInMilliseconds) {
    final duration = Duration(milliseconds: durationInMilliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
