import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';

class ReorderSongsInPlaylistUseCase {
  final PlaylistRepository _playlistRepository;

  ReorderSongsInPlaylistUseCase(this._playlistRepository);

  Future<Playlist> call(String playlistId, List<String> newOrder) async {
    if (playlistId.trim().isEmpty) {
      throw ArgumentError('Playlist ID cannot be empty');
    }
    
    if (newOrder.isEmpty) {
      throw ArgumentError('New order cannot be empty');
    }
    
    return _playlistRepository.reorderSongsInPlaylist(playlistId, newOrder);
  }
}