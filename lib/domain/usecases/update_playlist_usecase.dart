import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';

class UpdatePlaylistUseCase {
  final PlaylistRepository _playlistRepository;

  UpdatePlaylistUseCase(this._playlistRepository);

  Future<Playlist> call(Playlist playlist) async {
    if (playlist.title.trim().isEmpty) {
      throw ArgumentError('Playlist title cannot be empty');
    }
    
    return _playlistRepository.updatePlaylist(playlist);
  }
}