import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';

class SongsCubit extends Cubit<SongsState> {
  final SongsRepository _songsRepository;

  SongsCubit(this._songsRepository) : super(SongsState.initial()) {
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final songs = await _songsRepository.getSongs();
      emit(state.copyWith(songs: songs));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
