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
