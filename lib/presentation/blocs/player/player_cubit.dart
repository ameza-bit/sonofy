import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final PlayerRepository _playerRepository;

  PlayerCubit(this._playerRepository) : super(PlayerState.initial());

  Future<void> setPlayingSong(List<SongModel> playlist, SongModel song) async {
    final index = playlist.indexWhere((s) => s.id == song.id);
    final bool isPlaying = await _playerRepository.play(song.data);
    emit(
      state.copyWith(
        playlist: playlist,
        currentIndex: index,
        isPlaying: isPlaying,
      ),
    );
  }

  Future<void> nextSong() async {
    var currentIndex = state.currentIndex;
    if (currentIndex < state.playlist.length - 1) {
      currentIndex = currentIndex + 1;
    } else {
      currentIndex = 0;
    }
    final bool isPlaying = await _playerRepository.play(
      state.playlist[currentIndex].data,
    );
    emit(state.copyWith(currentIndex: currentIndex, isPlaying: isPlaying));
  }

  Future<void> previousSong() async {
    var currentIndex = state.currentIndex;
    if (currentIndex > 0) {
      currentIndex = currentIndex - 1;
    } else {
      currentIndex = state.playlist.length - 1;
    }
    final bool isPlaying = await _playerRepository.play(
      state.playlist[currentIndex].data,
    );
    emit(state.copyWith(currentIndex: currentIndex, isPlaying: isPlaying));
  }

  Future<void> togglePlayPause() async {
    final bool isPlaying = await _playerRepository.togglePlayPause();
    emit(state.copyWith(isPlaying: isPlaying));
  }

  Stream<int> getCurrentSongPosition() async* {
    while (true) {
      final position = await _playerRepository.getCurrentPosition();
      yield position?.inMilliseconds ?? 0;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> seekTo(Duration position) async {
    final bool isPlaying = await _playerRepository.seek(position);
    emit(state.copyWith(isPlaying: isPlaying));
  }
}
