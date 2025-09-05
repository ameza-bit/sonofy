import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

/// Clase utilitaria para convertir archivos de audio a objetos SongModel
/// 
/// Soporta múltiples formatos de audio: MP3, FLAC, WAV, AAC, OGG, M4A
/// Características:
/// - Extracción precisa de duración usando metadatos de AudioPlayer
/// - Sistema de caché inteligente para evitar recalcular duraciones
/// - Carga progresiva con soporte Stream para mejor UX
/// - Estimación de respaldo para archivos no soportados
/// - Procesamiento en paralelo para mejor rendimiento
class Mp3FileConverter {
  Mp3FileConverter._();

  /// Caché para almacenar cálculos de duración y evitar re-lecturas
  /// Formato de clave: "rutaArchivo:timestampModificacion"
  /// Esto asegura invalidación del caché cuando los archivos son modificados
  static final Map<String, int> _durationCache = {};

  /// Convierte una lista de archivos de audio a objetos SongModel con duración real
  /// 
  /// Esta es la versión síncrona que devuelve todos los resultados de una vez.
  /// Para listas de archivos grandes, considera usar [convertFilesToSongModelsStream] en su lugar.
  /// 
  /// [files] Lista de archivos de audio para convertir
  /// Devuelve un `Future<List<SongModel>>` con todas las canciones convertidas
  static Future<List<SongModel>> convertFilesToSongModels(
    List<File> files,
  ) async {
    final List<SongModel> songModels = [];
    for (final file in files) {
      final songModel = await _convertFileToSongModel(file);
      songModels.add(songModel);
    }
    return songModels;
  }

  /// Convierte archivos de audio a objetos SongModel con Stream para carga progresiva
  /// 
  /// Este método proporciona mejor UX al entregar resultados conforme están disponibles,
  /// permitiendo que la UI muestre canciones progresivamente en lugar de esperar todos los archivos.
  /// 
  /// Características:
  /// - Procesamiento en paralelo en lotes para rendimiento óptimo
  /// - Nivel de concurrencia configurable
  /// - Transmisión de resultados en tiempo real
  /// 
  /// [files] Lista de archivos de audio para convertir
  /// [concurrency] Número de archivos a procesar simultáneamente (predeterminado: 3)
  /// Devuelve un `Stream<SongModel>` que entrega canciones conforme son procesadas
  static Stream<SongModel> convertFilesToSongModelsStream(
    List<File> files, {
    int concurrency = 3,
  }) async* {
    // Process files in batches for better performance
    for (int i = 0; i < files.length; i += concurrency) {
      final batch = files.skip(i).take(concurrency).toList();
      
      // Process batch in parallel
      final futures = batch.map(_convertFileToSongModel);
      final results = await Future.wait(futures);
      
      // Yield each result as it becomes available
      for (final songModel in results) {
        yield songModel;
      }
    }
  }

  /// Convierte un archivo de audio individual a SongModel con duración real y metadatos ID3
  /// 
  /// Extrae metadatos incluyendo duración precisa e información de ID3 tags de archivos de audio.
  /// Soporta todos los formatos principales: MP3, FLAC, WAV, AAC, OGG, M4A
  /// 
  /// [file] Archivo de audio para convertir
  /// Devuelve SongModel con metadatos precisos
  static Future<SongModel> _convertFileToSongModel(File file) async {
    final fileName = file.path.split('/').last;
    final title = fileName.split('.').first;

    // Extract detailed metadata from ID3 tags first
    final metadata = await _extractDetailedMetadata(file);

    // Use metadata if available, fallback to filename parsing
    final String artistName = metadata['artist'] ?? _extractArtistFromFileName(fileName);
    final String albumName = metadata['album'] ?? 'Local Files';
    final String songTitle = metadata['title'] ?? title;
    final String genre = metadata['genres'] ?? 'Unknown';
    final int? year = metadata['year'];
    final int? trackNumber = metadata['track'];
    final int? discNumber = metadata['discNumber'];
    final int? bitrate = metadata['bitrate'];
    final int? sampleRate = metadata['sampleRate'];
    final String? language = metadata['language'];
    final String? lyrics = metadata['lyrics'];
    final String? performers = metadata['performers'];

    // Use metadata duration if available, otherwise calculate from AudioPlayer
    final int durationMs = metadata['duration'] ?? await _getActualDurationFromFile(file);

    return SongModel({
      '_id': _createPersistentIdFromPath(file.path),
      '_data': file.path,
      '_display_name': fileName,
      '_display_name_wo_ext': title,
      'file_extension': fileName.split('.').last,
      'is_music': true,
      'title': songTitle,
      'artist': artistName,
      'album': albumName,
      'genre': genre,
      'year': year,
      'track': trackNumber,
      'disc_number': discNumber,
      'bitrate': bitrate,
      'sample_rate': sampleRate,
      'language': language,
      'lyrics': lyrics,
      'performers': performers,
      '_size': file.lengthSync(),
      'duration': durationMs,
      'album_id': albumName.hashCode,
      'artist_id': artistName.hashCode,
      'date_added': DateTime.now().millisecondsSinceEpoch,
      'date_modified': file.lastModifiedSync().millisecondsSinceEpoch,
    });
  }

  /// Extrae metadatos detallados del archivo usando audio_metadata_reader
  /// 
  /// Obtiene información completa de metadatos incluyendo título, artista, álbum,
  /// género, año, número de pista y más campos disponibles en los tags del archivo.
  /// 
  /// [file] Archivo de audio para analizar
  /// Devuelve Map con los metadatos extraídos
  static Future<Map<String, dynamic>> _extractDetailedMetadata(File file) async {
    try {
      final metadata = readMetadata(file, getImage: true);
      
      final performersText = metadata.performers.isNotEmpty ? metadata.performers.join(', ') : null;
      final genresText = metadata.genres.isNotEmpty ? metadata.genres.join(', ') : null;
      final yearNumber = metadata.year?.year;
      
      return {
        'title': metadata.title?.trim(),
        'artist': metadata.artist?.trim(), 
        'album': metadata.album?.trim(),
        'year': yearNumber,
        'track': metadata.trackNumber,
        'discNumber': metadata.discNumber,
        'bitrate': metadata.bitrate,
        'sampleRate': metadata.sampleRate,
        'duration': metadata.duration?.inMilliseconds,
        'language': metadata.language?.trim(),
        'lyrics': metadata.lyrics?.trim(),
        'performers': performersText,
        'genres': genresText,
      };
    } catch (e) {
      // Si no se pueden leer los metadatos, devolver valores nulos
      return <String, dynamic>{};
    }
  }

  /// Extracts artist name from filename using common patterns
  /// Supports formats: "Artist - Song.mp3", "Artist_Song.mp3"
  static String _extractArtistFromFileName(String fileName) {
    final nameWithoutExt = fileName.split('.').first;

    if (nameWithoutExt.contains(' - ')) {
      return nameWithoutExt.split(' - ').first.trim();
    } else if (nameWithoutExt.contains('_')) {
      final parts = nameWithoutExt.split('_');
      if (parts.length >= 2) {
        return parts.first.trim();
      }
    }

    return 'Unknown Artist';
  }

  /// Creates a persistent ID for local files based on file path
  /// This ensures the same file always gets the same ID across app sessions
  static int _createPersistentIdFromPath(String filePath) {
    // Use a hash of the file path to create a consistent ID
    // Add a large offset to avoid conflicts with on_audio_query_pluse IDs
    const int localFileIdOffset = 1000000;
    return filePath.hashCode.abs() + localFileIdOffset;
  }

  /// Obtiene la duración real del archivo de audio usando AudioPlayer
  /// 
  /// Este método proporciona duración precisa para todos los formatos soportados
  /// cargando temporalmente el archivo con AudioPlayer para leer sus metadatos.
  /// 
  /// Características:
  /// - Caché inteligente con detección de modificación de archivos
  /// - Respaldo elegante a estimación basada en tamaño
  /// - Eficiente en memoria (desecha AudioPlayer inmediatamente)
  /// - Soporte para todos los formatos compatibles con AudioPlayer
  /// 
  /// [file] Archivo de audio para analizar
  /// Devuelve duración en milisegundos
  static Future<int> _getActualDurationFromFile(File file) async {
    final filePath = file.path;
    final lastModified = file.lastModifiedSync().millisecondsSinceEpoch;
    final cacheKey = '$filePath:$lastModified';

    // Check cache first
    if (_durationCache.containsKey(cacheKey)) {
      return _durationCache[cacheKey]!;
    }

    try {
      final player = AudioPlayer();
      await player.setSource(DeviceFileSource(filePath));

      // Wait a moment for the audio to be loaded
      await Future.delayed(const Duration(milliseconds: 500));

      final duration = await player.getDuration();
      await player.dispose();

      final durationMs = duration?.inMilliseconds ??
          _estimateDurationFromFileSize(file.lengthSync());

      // Cache the result
      _durationCache[cacheKey] = durationMs;
      
      return durationMs;
    } catch (e) {
      // Fallback to file size estimation if unable to read metadata
      final durationMs = _estimateDurationFromFileSize(file.lengthSync());
      _durationCache[cacheKey] = durationMs;
      return durationMs;
    }
  }

  /// Estima la duración del audio basándose en el tamaño del archivo (método de respaldo)
  /// 
  /// Se usa cuando AudioPlayer no puede leer metadatos del archivo.
  /// Esta es una estimación aproximada basada en bitrate promedio de MP3.
  /// 
  /// Nota: Esta estimación puede ser imprecisa para:
  /// - Archivos con bitrate variable
  /// - Formatos sin pérdida (FLAC, WAV)
  /// - Archivos con codificación no estándar
  /// 
  /// [fileSizeBytes] Tamaño del archivo de audio en bytes
  /// Devuelve duración estimada en milisegundos
  static int _estimateDurationFromFileSize(int fileSizeBytes) {
    const int averageBytesPerSecond = 16000; // 128kbps / 8 = 16KB/s
    final int estimatedSeconds = fileSizeBytes ~/ averageBytesPerSecond;
    return estimatedSeconds * 1000; // Convert to milliseconds
  }
}
