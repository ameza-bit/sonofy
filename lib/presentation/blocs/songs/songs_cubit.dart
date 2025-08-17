import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/domain/usecases/get_local_songs_usecase.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';

class SongsCubit extends Cubit<SongsState> {
  final SongsRepository _songsRepository;
  final GetLocalSongsUseCase? _getLocalSongsUseCase;

  SongsCubit(this._songsRepository, this._getLocalSongsUseCase)
    : super(SongsState.initial()) {
    loadAllSongs();
  }

  Future<void> loadAllSongs() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Obtener canciones del dispositivo
      final deviceSongs = await _songsRepository.getSongsFromDevice();

      // Para iOS: combinar canciones del dispositivo + canciones locales
      // Para Android: solo canciones del dispositivo (incluye toda la música)
      if (!kIsWeb && Platform.isIOS && _getLocalSongsUseCase != null) {
        final localSongs = await _getLocalSongsUseCase();

        final allSongs = <SongModel>[];
        allSongs.addAll(deviceSongs);
        allSongs.addAll(localSongs);

        emit(
          state.copyWith(
            songs: allSongs,
            deviceSongs: deviceSongs,
            localSongs: localSongs,
            isLoading: false,
          ),
        );
      } else {
        // Android: solo canciones del dispositivo
        emit(
          state.copyWith(
            songs: deviceSongs,
            deviceSongs: deviceSongs,
            localSongs: [], // Android no tiene canciones locales separadas
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadDeviceSongs() async {
    try {
      emit(state.copyWith(isLoading: true));

      final deviceSongs = await _songsRepository.getSongsFromDevice();

      if (!kIsWeb && Platform.isIOS) {
        // iOS: combinar con canciones locales existentes
        final allSongs = <SongModel>[];
        allSongs.addAll(deviceSongs);
        allSongs.addAll(state.localSongs);

        emit(
          state.copyWith(
            songs: allSongs,
            deviceSongs: deviceSongs,
            isLoading: false,
          ),
        );
      } else {
        // Android: solo canciones del dispositivo
        emit(
          state.copyWith(
            songs: deviceSongs,
            deviceSongs: deviceSongs,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> loadLocalSongs() async {
    // Solo iOS soporta canciones locales de carpetas específicas
    if (kIsWeb || Platform.isAndroid || _getLocalSongsUseCase == null) {
      return; // Android no tiene canciones locales separadas
    }

    try {
      emit(state.copyWith(isLoadingLocal: true));

      final localSongs = await _getLocalSongsUseCase();

      // Combinar con canciones del dispositivo existentes (solo iOS)
      final allSongs = <SongModel>[];
      allSongs.addAll(state.deviceSongs);
      allSongs.addAll(localSongs);

      emit(
        state.copyWith(
          songs: allSongs,
          localSongs: localSongs,
          isLoadingLocal: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingLocal: false));
    }
  }

  Future<void> refreshLocalSongs() async {
    await loadLocalSongs();
  }

  void filterSongs(String query) {
    if (query.isEmpty) {
      // Mostrar todas las canciones según la plataforma
      if (!kIsWeb && Platform.isIOS) {
        final allSongs = <SongModel>[];
        allSongs.addAll(state.deviceSongs);
        allSongs.addAll(state.localSongs);
        emit(state.copyWith(songs: allSongs));
      } else {
        // Android: solo canciones del dispositivo
        emit(state.copyWith(songs: state.deviceSongs));
      }
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
    // Solo iOS tiene canciones locales
    if (!kIsWeb && Platform.isIOS) {
      emit(state.copyWith(songs: state.localSongs));
    }
  }

  void showOnlyDeviceSongs() {
    emit(state.copyWith(songs: state.deviceSongs));
  }

  void showAllSongs() {
    if (!kIsWeb && Platform.isIOS) {
      // iOS: combinar canciones del dispositivo + locales
      final allSongs = <SongModel>[];
      allSongs.addAll(state.deviceSongs);
      allSongs.addAll(state.localSongs);
      emit(state.copyWith(songs: allSongs));
    } else {
      // Android: solo canciones del dispositivo (que incluye toda la música)
      emit(state.copyWith(songs: state.deviceSongs));
    }
  }
}
