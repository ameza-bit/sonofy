import 'package:sonofy/domain/repositories/songs_repository.dart';

class SelectMusicFolderUseCase {
  final SongsRepository _songsRepository;

  SelectMusicFolderUseCase(this._songsRepository);

  Future<String?> call() async {
    return _songsRepository.selectMusicFolder();
  }
}