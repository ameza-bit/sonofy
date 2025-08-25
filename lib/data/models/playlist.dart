class Playlist {
  final String id;
  final String title;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Playlist({
    required this.id,
    required this.title,
    required this.songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  int get songCount => songIds.length;
  bool get isEmpty => songIds.isEmpty;
  bool get isNotEmpty => songIds.isNotEmpty;

  bool containsSong(String songId) => songIds.contains(songId);

  Playlist addSong(String songId) {
    if (songIds.contains(songId)) return this;
    return copyWith(
      songIds: [...songIds, songId],
      updatedAt: DateTime.now(),
    );
  }

  Playlist removeSong(String songId) {
    final newSongIds = songIds.where((id) => id != songId).toList();
    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  Playlist reorderSongs(List<String> newOrder) {
    return copyWith(
      songIds: newOrder,
      updatedAt: DateTime.now(),
    );
  }

  Playlist rename(String newTitle) {
    return copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
  }

  Playlist copyWith({
    String? id,
    String? title,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    songIds: List<String>.from(json['songIds'] ?? []),
    createdAt: DateTime.parse(
      json['createdAt'] ?? DateTime.now().toIso8601String(),
    ),
    updatedAt: DateTime.parse(
      json['updatedAt'] ?? DateTime.now().toIso8601String(),
    ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'songIds': songIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
