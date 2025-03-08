import 'package:audioplayers/audioplayers.dart';

class Song {
  final int id;
  final String title;
  final AssetSource musicSource;
  final String artist;
  final String coverUrl;

  Song({
    required this.id,
    required this.title,
    required this.musicSource,
    this.artist = '',
    this.coverUrl = '',
  });
}
