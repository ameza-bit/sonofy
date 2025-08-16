import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/usecases/get_all_songs_usecase.dart';
import 'package:sonofy/domain/usecases/get_local_songs_usecase.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';

class SongsCubit extends Cubit<SongsState> {
  final SongsRepository _songsRepository;
  final GetAllSongsUseCase _getAllSongsUseCase;
  final GetLocalSongsUseCase _getLocalSongsUseCase;

  SongsCubit(
    this._songsRepository,
    this._getAllSongsUseCase,
    this._getLocalSongsUseCase,
  ) : super(SongsState.initial()) {
    loadAllSongs();
  }

  Future<void> loadAllSongs() async {
    try {
      emit(state.copyWith(isLoading: true));

      final allSongs = await _getAllSongsUseCase();
      final deviceSongs = await _songsRepository.getSongsFromDevice();
      final localSongs = await _getLocalSongsUseCase();

      emit(state.copyWith(
        songs: allSongs,
        deviceSongs: deviceSongs,
        localSongs: localSongs,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadDeviceSongs() async {
    try {
      emit(state.copyWith(isLoading: true));

      final deviceSongs = await _songsRepository.getSongsFromDevice();
      
      // Combinar con canciones locales existentes
      final allSongs = <SongModel>[];
      allSongs.addAll(deviceSongs);
      allSongs.addAll(state.localSongs);

      emit(state.copyWith(
        songs: allSongs,
        deviceSongs: deviceSongs,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadLocalSongs() async {
    try {
      emit(state.copyWith(isLoadingLocal: true));

      final localSongs = await _getLocalSongsUseCase();
      
      // Combinar con canciones del dispositivo existentes
      final allSongs = <SongModel>[];
      allSongs.addAll(state.deviceSongs);
      allSongs.addAll(localSongs);

      emit(state.copyWith(
        songs: allSongs,
        localSongs: localSongs,
        isLoadingLocal: false,
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingLocal: false));
    }
  }

  Future<void> refreshLocalSongs() async {
    await loadLocalSongs();
  }

  void filterSongs(String query) {
    if (query.isEmpty) {
      // Mostrar todas las canciones
      final allSongs = <SongModel>[];
      allSongs.addAll(state.deviceSongs);
      allSongs.addAll(state.localSongs);
      emit(state.copyWith(songs: allSongs));
    } else {
      // Filtrar canciones
      final filteredSongs = state.songs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
               song.artist!.toLowerCase().contains(query.toLowerCase()) ||
               song.album!.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      emit(state.copyWith(songs: filteredSongs));
    }
  }

  void showOnlyLocalSongs() {
    emit(state.copyWith(songs: state.localSongs));
  }

  void showOnlyDeviceSongs() {
    emit(state.copyWith(songs: state.deviceSongs));
  }

  void showAllSongs() {
    final allSongs = <SongModel>[];
    allSongs.addAll(state.deviceSongs);
    allSongs.addAll(state.localSongs);
    emit(state.copyWith(songs: allSongs));
  }
}
