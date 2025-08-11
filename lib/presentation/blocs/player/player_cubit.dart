import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerState.initial());

  void setPlaylist(List<SongModel> playlist) {
    emit(state.copyWith(playlist: playlist));
  }

  void setCurrentIndex(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}
