import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerRepository _playerRepository;

  PlayerCubit(this._playerRepository) : super(PlayerState.initial());

  void setPlayingSong(List<SongModel> songs, int i) {
    _playerRepository.play(songs[i].uri!);
    emit(state.copyWith(playlist: songs, currentIndex: i));
  }

  void nextSong() {
    final currentIndex = state.currentIndex;
    if (currentIndex < state.playlist.length - 1) {
      emit(state.copyWith(currentIndex: currentIndex + 1));
    } else {
      emit(state.copyWith(currentIndex: 0));
    }
  }

  void previousSong() {
    final currentIndex = state.currentIndex;
    if (currentIndex > 0) {
      emit(state.copyWith(currentIndex: currentIndex - 1));
    } else {
      emit(state.copyWith(currentIndex: state.playlist.length - 1));
    }
  }
}
