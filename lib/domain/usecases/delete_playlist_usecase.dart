import 'package:sonofy/domain/repositories/playlist_repository.dart';

class DeletePlaylistUseCase {
  final PlaylistRepository _playlistRepository;

  DeletePlaylistUseCase(this._playlistRepository);

  Future<void> call(String playlistId) async {
    if (playlistId.trim().isEmpty) {
      throw ArgumentError('Playlist ID cannot be empty');
    }
    
    await _playlistRepository.deletePlaylist(playlistId);
  }
}