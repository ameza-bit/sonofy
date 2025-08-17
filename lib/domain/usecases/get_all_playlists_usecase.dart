import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';

class GetAllPlaylistsUseCase {
  final PlaylistRepository _playlistRepository;

  GetAllPlaylistsUseCase(this._playlistRepository);

  Future<List<Playlist>> call() async {
    return _playlistRepository.getAllPlaylists();
  }
}