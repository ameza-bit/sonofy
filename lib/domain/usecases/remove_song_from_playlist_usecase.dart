import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';

class RemoveSongFromPlaylistUseCase {
  final PlaylistRepository _playlistRepository;

  RemoveSongFromPlaylistUseCase(this._playlistRepository);

  Future<Playlist> call(String playlistId, String songId) async {
    if (playlistId.trim().isEmpty) {
      throw ArgumentError('Playlist ID cannot be empty');
    }
    
    if (songId.trim().isEmpty) {
      throw ArgumentError('Song ID cannot be empty');
    }
    
    return _playlistRepository.removeSongFromPlaylist(playlistId, songId);
  }
}