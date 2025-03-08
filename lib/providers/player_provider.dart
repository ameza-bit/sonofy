import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  bool get isPlaying => player.state == PlayerState.playing;

  Future<void> play() async {
    try {
      await player.setSource(AssetSource('music/wasteland.mp3'));
      await player.resume();
    } catch (e) {
      debugPrint('Error Playing: $e');
    }
  }

  void toggleState() {
    if (isPlaying) {
      player.pause();
    } else {
      player.resume();
    }
    notifyListeners();
  }
}
