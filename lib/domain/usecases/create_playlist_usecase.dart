import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';

class CreatePlaylistUseCase {
  final PlaylistRepository _playlistRepository;

  CreatePlaylistUseCase(this._playlistRepository);

  Future<Playlist> call(String name) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('Playlist name cannot be empty');
    }
    
    return _playlistRepository.createPlaylist(name.trim());
  }
}