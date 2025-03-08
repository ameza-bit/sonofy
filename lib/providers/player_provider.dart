import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:sonofy/models/song.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  final List<Song> _playlist = [
    Song(
      id: 1,
      title: "Wasteland",
      musicSource: AssetSource('music/Wasteland.mp3'),
      coverUrl: "https://i.scdn.co/image/ab67616d00001e0290d7c2223cf5fa97a2fcf993",
    ),
    Song(
      id: 2,
      title: "Kokoro no Kara",
      musicSource: AssetSource('music/Kokoro no Kara.mp3'),
      coverUrl: "https://i1.sndcdn.com/artworks-tV6EFRdr6N148eFK-icc92w-t500x500.jpg",
    ),
    Song(
      id: 3,
      title: "Survive the Night",
      artist: "MandoPony",
      musicSource: AssetSource('music/Survive the Night.mp3'),
    ),
    Song(
      id: 4,
      title: "Why, or why not",
      artist: "Hiroyuki Sawano",
      musicSource: AssetSource('music/Why, or why not.mp3'),
    ),
  ];

  Song? _currentSong;

  List<Song> get playlist => _playlist;

  bool get hasSong => _currentSong != null;
  Song? get currentSong => _currentSong;
  set currentSong(Song? song) {
    _currentSong = song;
    if (song != null) {
      player.setSource(song.musicSource).then((_) {
        player.resume();
      });
    }
    notifyListeners();
  }

  bool get isPlaying => player.state == PlayerState.playing;

  void toggleState() {
    if (isPlaying) {
      player.pause();
    } else {
      player.resume();
    }
    notifyListeners();
  }
}
