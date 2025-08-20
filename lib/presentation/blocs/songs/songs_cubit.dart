import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/enums/order_by.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';
import 'package:sonofy/domain/usecases/get_local_songs_usecase.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';

/// Cubit para manejar estado y operaciones de biblioteca musical
///
/// Este cubit maneja:
/// - Carga de canciones desde biblioteca musical nativa del dispositivo
/// - Carga de canciones desde directorios locales (solo iOS)
/// - Carga progresiva con actualizaciones de UI en tiempo real
/// - Filtrado y ordenamiento de canciones
/// - Diferencias de comportamiento específicas de plataforma
///
/// Características:
/// - Carga de datos multi-fuente (dispositivo + locales)
/// - Carga progresiva con soporte Stream
/// - Seguimiento de progreso en tiempo real
/// - Caché inteligente a través de servicios subyacentes
/// - Ordenamiento automático basado en preferencias del usuario
class SongsCubit extends Cubit<SongsState> {
  final SongsRepository _songsRepository;
  final GetLocalSongsUseCase? _getLocalSongsUseCase;
  final SettingsRepository _settingsRepository;

  SongsCubit(
    this._songsRepository,
    this._getLocalSongsUseCase,
    this._settingsRepository,
  ) : super(SongsState.initial()) {
    loadAllSongs();
  }

  OrderBy get _currentOrderBy => _settingsRepository.getSettings().orderBy;

  List<SongModel> _applySorting(List<SongModel> songs) {
    return _currentOrderBy.applySorting(songs);
  }

  Future<void> loadAllSongs() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Obtener canciones del dispositivo
      final deviceSongs = await _songsRepository.getSongsFromDevice();

      // Para iOS: combinar canciones del dispositivo + canciones locales
      // Para Android: solo canciones del dispositivo (incluye toda la música)
      if (!kIsWeb && Platform.isIOS && _getLocalSongsUseCase != null) {
        // Cargar canciones del dispositivo primero
        emit(
          state.copyWith(
            songs: _applySorting(deviceSongs),
            deviceSongs: deviceSongs,
            isLoading: false,
          ),
        );

        // Luego cargar canciones locales progresivamente
        await loadLocalSongsProgressive();
      } else {
        // Android: solo canciones del dispositivo
        emit(
          state.copyWith(
            songs: _applySorting(deviceSongs),
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
            songs: _applySorting(allSongs),
            deviceSongs: deviceSongs,
            isLoading: false,
          ),
        );
      } else {
        // Android: solo canciones del dispositivo
        emit(
          state.copyWith(
            songs: _applySorting(deviceSongs),
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

      final localSongs = await _getLocalSongsUseCase.call();

      // Combinar con canciones del dispositivo existentes (solo iOS)
      final allSongs = <SongModel>[];
      allSongs.addAll(state.deviceSongs);
      allSongs.addAll(localSongs);

      emit(
        state.copyWith(
          songs: _applySorting(allSongs),
          localSongs: localSongs,
          isLoadingLocal: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoadingLocal: false));
    }
  }

  Future<void> loadLocalSongsProgressive() async {
    // Solo iOS soporta canciones locales de carpetas específicas
    if (kIsWeb || Platform.isAndroid || _getLocalSongsUseCase == null) {
      return; // Android no tiene canciones locales separadas
    }

    try {
      // Primero obtenemos el total de archivos para mostrar progreso
      final settings = _settingsRepository.getSettings();
      final localPath = settings.localMusicPath;
      if (localPath == null || localPath.isEmpty) {
        return;
      }

      final files = await _songsRepository.getSongsFromFolder(localPath);
      final totalFiles = files.length;

      if (totalFiles == 0) {
        emit(
          state.copyWith(
            localSongs: [],
            isLoadingProgressive: false,
            loadedCount: 0,
            totalCount: 0,
          ),
        );
        return;
      }

      // Inicializar carga progresiva
      emit(
        state.copyWith(
          isLoadingProgressive: true,
          loadedCount: 0,
          totalCount: totalFiles,
          localSongs: [], // Limpiar canciones locales anteriores
        ),
      );

      final localSongs = <SongModel>[];
      int loadedCount = 0;

      // Usar Stream para carga progresiva
      await for (final song in _getLocalSongsUseCase.callStream()) {
        localSongs.add(song);
        loadedCount++;

        // Combinar con canciones del dispositivo
        final allSongs = <SongModel>[];
        allSongs.addAll(state.deviceSongs);
        allSongs.addAll(localSongs);

        emit(
          state.copyWith(
            songs: _applySorting(allSongs),
            localSongs: localSongs,
            loadedCount: loadedCount,
            isLoadingProgressive: loadedCount < totalFiles,
          ),
        );
      }

      // Finalizar carga
      emit(
        state.copyWith(isLoadingProgressive: false, loadedCount: totalFiles),
      );
    } catch (e) {
      emit(
        state.copyWith(
          error: e.toString(),
          isLoadingProgressive: false,
          loadedCount: 0,
          totalCount: 0,
        ),
      );
    }
  }

  Future<void> refreshLocalSongs() async {
    await loadLocalSongsProgressive();
  }

  void filterSongs(String query, [OrderBy? orderBy]) {
    List<SongModel> songsToFilter;

    // Obtener todas las canciones disponibles según la plataforma
    List<SongModel> allAvailableSongs;
    if (!kIsWeb && Platform.isIOS) {
      allAvailableSongs = <SongModel>[];
      allAvailableSongs.addAll(state.deviceSongs);
      allAvailableSongs.addAll(state.localSongs);
    } else {
      // Android: solo canciones del dispositivo
      allAvailableSongs = state.deviceSongs;
    }

    if (query.isEmpty) {
      // Mostrar todas las canciones
      songsToFilter = allAvailableSongs;
    } else {
      // Filtrar desde todas las canciones disponibles
      songsToFilter = allAvailableSongs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            (song.artist ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (song.album ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    // Aplicar ordenamiento
    final currentOrderBy = orderBy ?? _currentOrderBy;
    songsToFilter = currentOrderBy.applySorting(songsToFilter);

    emit(state.copyWith(songs: songsToFilter));
  }

  void showOnlyLocalSongs([OrderBy? orderBy]) {
    // Solo iOS tiene canciones locales
    if (!kIsWeb && Platform.isIOS) {
      final currentOrderBy = orderBy ?? _currentOrderBy;
      final sortedLocalSongs = currentOrderBy.applySorting(state.localSongs);
      emit(state.copyWith(songs: sortedLocalSongs));
    }
  }

  void showOnlyDeviceSongs([OrderBy? orderBy]) {
    final currentOrderBy = orderBy ?? _currentOrderBy;
    final sortedDeviceSongs = currentOrderBy.applySorting(state.deviceSongs);
    emit(state.copyWith(songs: sortedDeviceSongs));
  }

  void showAllSongs([OrderBy? orderBy]) {
    List<SongModel> allSongs;

    if (!kIsWeb && Platform.isIOS) {
      // iOS: combinar canciones del dispositivo + locales
      allSongs = <SongModel>[];
      allSongs.addAll(state.deviceSongs);
      allSongs.addAll(state.localSongs);
    } else {
      // Android: solo canciones del dispositivo (que incluye toda la música)
      allSongs = state.deviceSongs;
    }

    final currentOrderBy = orderBy ?? _currentOrderBy;
    allSongs = currentOrderBy.applySorting(allSongs);

    emit(state.copyWith(songs: allSongs));
  }

  void applySorting(OrderBy orderBy) {
    final sortedSongs = orderBy.applySorting(state.songs);
    emit(state.copyWith(songs: sortedSongs));
  }
}
