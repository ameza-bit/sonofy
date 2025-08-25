import 'dart:io';
import 'package:sonofy/domain/repositories/songs_repository.dart';

class GetSongsFromFolderUseCase {
  final SongsRepository _songsRepository;

  GetSongsFromFolderUseCase(this._songsRepository);

  Future<List<File>> call(String folderPath) async {
    return _songsRepository.getSongsFromFolder(folderPath);
  }
}