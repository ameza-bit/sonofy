import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  AssetSource source = AssetSource('assets/music/wasteland.mp3');
  final player = AudioPlayer();

  void play() {
    player.play(source);
    notifyListeners();
  }
}
