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
  // Añadir propiedades para posición y duración
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  List<Song> get playlist => _playlist;

  // Getters para la posición y duración
  Duration get position => _position;
  Duration get duration => _duration;

  Song? get currentSong => _currentSong;

  bool get isPlaying => player.state == PlayerState.playing;

  // Constructor con listeners para actualizar posición y duración
  Future<void> setCurrentSong(Song song) async {
    // Escuchar cambios de posición
    player.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });

    // Escuchar cambios de duración
    player.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    try {
      _currentSong = song;
      await player.setSource(song.musicSource);
      await player.resume();
    } catch (e) {
      debugPrint("Error on setCurrentSong: $e");
    } finally {
      notifyListeners();
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

  // Método para buscar una posición específica en la canción
  Future<void> seek(Duration position) async {
    await player.seek(position);
  }
}
