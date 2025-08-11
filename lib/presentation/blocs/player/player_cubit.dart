import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerState.initial());

  void setPlayingSong(List<SongModel> songs, int i) {
    emit(state.copyWith(playlist: songs, currentIndex: i));
  }
}
