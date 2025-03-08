import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sonofy/models/song.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  final List<Song> _playlist = [
    Song(
      id: 1,
      title: "wasteland",
      musicSource: AssetSource('music/Wasteland.mp3'),
    ),
    Song(
      id: 2,
      title: "Kokoro no Kara",
      musicSource: AssetSource('music/Kokoro no Kara.mp3'),
    ),
    Song(
      id: 3,
      title: "Survive the Night",
      musicSource: AssetSource('music/Survive the Night.mp3'),
    ),
    Song(
      id: 4,
      title: "Why, or why not",
      musicSource: AssetSource('music/Why, or why not.mp3'),
    ),
  ];

  List<Song> get playlist => _playlist;

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
