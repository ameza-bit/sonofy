import 'dart:io';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/functions.dart' show getMusicFolderPath;
import 'package:sonofy/core/utils/mp3_file_converter.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';

/// Caso de uso para cargar archivos de audio locales con soporte de carga progresiva
///
/// Este caso de uso maneja la carga de archivos de audio desde directorios locales (solo iOS)
/// y proporciona APIs tanto síncronas como de streaming para diferentes casos de uso.
///
/// Características:
/// - Carga síncrona: [call] - Devuelve todas las canciones de una vez
/// - Carga progresiva: [callStream] - Transmite canciones conforme son procesadas
/// - Soporte multi-formato: MP3, FLAC, WAV, AAC, OGG, M4A
/// - Extracción precisa de duración para todos los formatos soportados
/// - Comportamiento específico de plataforma (solo iOS)
class GetLocalSongsUseCase {
  final SongsRepository _songsRepository;

  GetLocalSongsUseCase(this._songsRepository);

  /// Carga todas las canciones locales de forma síncrona
  ///
  /// Este método carga todas las canciones del directorio de música local configurado
  /// y las devuelve como una lista completa. Para mejor UX con bibliotecas grandes,
  /// considera usar [callStream] en su lugar.
  ///
  /// Soporte de plataforma: Solo iOS (Android devuelve lista vacía)
  ///
  /// Devuelve `List<SongModel>` con todas las canciones locales
  Future<List<SongModel>> call() async {
    // Solo iOS soporta canciones locales de carpetas específicas
    if (Platform.isAndroid) {
      return []; // Android no tiene canciones "locales" separadas
    }

    try {
      final localPath = await getMusicFolderPath();
      if (localPath.isEmpty) {
        return [];
      }

      final files = await _songsRepository.getSongsFromFolder(localPath);

      // Convert files to SongModel using utility
      return await Mp3FileConverter.convertFilesToSongModels(files);
    } catch (e) {
      return [];
    }
  }

  /// Carga canciones locales progresivamente usando Stream
  ///
  /// Este método proporciona una mejor experiencia de usuario transmitiendo canciones
  /// conforme son procesadas, permitiendo que la UI muestre progreso y resultados
  /// en tiempo real en lugar de esperar a que todos los archivos sean procesados.
  ///
  /// Beneficios:
  /// - Actualizaciones progresivas de UI
  /// - Mejor rendimiento percibido
  /// - Procesamiento en paralelo con concurrencia configurable
  /// - Retroalimentación inmediata a los usuarios
  ///
  /// Soporte de plataforma: Solo iOS (Android termina stream inmediatamente)
  ///
  /// Devuelve `Stream<SongModel>` que entrega canciones conforme son procesadas
  Stream<SongModel> callStream() async* {
    // Solo iOS soporta canciones locales de carpetas específicas
    if (Platform.isAndroid) {
      return; // Android no tiene canciones "locales" separadas
    }

    try {
      final localPath = await getMusicFolderPath();
      if (localPath.isEmpty) {
        return;
      }

      final files = await _songsRepository.getSongsFromFolder(localPath);

      // Convert files to SongModel using Stream for progressive loading
      yield* Mp3FileConverter.convertFilesToSongModelsStream(files);
    } catch (e) {
      // Stream ends on error
      return;
    }
  }
}
