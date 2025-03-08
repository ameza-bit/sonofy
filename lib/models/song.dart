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
    this.artist = 'Unknown Artist',
    this.coverUrl = '',
  });

  String get songCover => coverUrl.isNotEmpty ? coverUrl : 'https://placehold.co/600x400?text=${title.replaceAll(' ', '_')}';
}
