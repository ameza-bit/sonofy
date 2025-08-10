class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String lyrics;
  final String imageUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.lyrics,
    required this.imageUrl,
  });

  Song.empty()
    : id = '-1',
      title = 'Dummy Song Name',
      artist = 'My Sweet Piano',
      album = 'Onegai My Melody',
      lyrics = '',
      imageUrl = 'assets/images/piano.png';

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    artist: json['artist'] ?? '',
    album: json['album'] ?? '',
    lyrics: json['lyrics'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'album': album,
    'lyrics': lyrics,
    'imageUrl': imageUrl,
  };
}
