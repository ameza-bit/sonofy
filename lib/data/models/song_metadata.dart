import 'dart:io' show File;

import 'package:audio_metadata_reader/audio_metadata_reader.dart'
    as amr
    show Picture, readMetadata;
import 'package:easy_localization/easy_localization.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart' show SongModel;

class SongMetadata {
  final String title;
  final String artist;
  final String album;
  final String composer;
  final String genre;
  final int year;
  final int trackNumber;
  final int trackTotal;
  final int discNumber;
  final int duration; // en milisegundos
  final int bitrate;
  final int sampleRate;
  final String language;
  final String lyrics;
  final List<String> performers;
  final List<String> genres;
  final amr.Picture? artwork;
  final String filePath;
  final String fileName;
  final String fileExtension;
  final int fileSize;
  final DateTime dateAdded;
  final DateTime dateModified;

  SongMetadata({
    required this.title,
    required this.artist,
    required this.album,
    required this.composer,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.trackTotal,
    required this.discNumber,
    required this.duration,
    required this.bitrate,
    required this.sampleRate,
    required this.language,
    required this.lyrics,
    required this.performers,
    required this.genres,
    required this.artwork,
    required this.filePath,
    required this.fileName,
    required this.fileExtension,
    required this.fileSize,
    required this.dateAdded,
    required this.dateModified,
  });

  factory SongMetadata.fromSongModel(SongModel song) {
    final file = File(song.data);
    final metadata = amr.readMetadata(file);

    final genresText = metadata.genres.isNotEmpty
        ? metadata.genres.join(', ')
        : null;
    final yearNumber = metadata.year?.year;

    // Extraer la primera imagen disponible (artwork/cover)
    final artwork = metadata.pictures.isNotEmpty
        ? metadata.pictures.first
        : null;

    return SongMetadata(
      title: metadata.title ?? song.title,
      artist: metadata.artist ?? song.artist ?? 'common.unknown_artist'.tr(),
      album: metadata.album ?? song.album ?? 'common.unknown_album'.tr(),
      composer: song.composer ?? '',
      genre: genresText ?? song.genre ?? '',
      year: yearNumber ?? 0,
      trackNumber: metadata.trackNumber ?? 0,
      trackTotal: metadata.trackTotal ?? 0,
      discNumber: metadata.discNumber ?? 0,
      duration: metadata.duration?.inMilliseconds ?? song.duration ?? 0,
      bitrate: metadata.bitrate ?? 0,
      sampleRate: metadata.sampleRate ?? 0,
      language: metadata.language ?? '',
      lyrics: metadata.lyrics ?? '',
      performers: metadata.performers,
      genres: metadata.genres,
      artwork: artwork,
      filePath: song.data,
      fileName: song.displayName,
      fileExtension: song.fileExtension,
      fileSize: song.size,
      dateAdded: DateTime.fromMillisecondsSinceEpoch(
        song.dateAdded ?? file.lastModifiedSync().millisecondsSinceEpoch,
      ),
      dateModified: DateTime.fromMillisecondsSinceEpoch(
        song.dateModified ?? file.lastModifiedSync().millisecondsSinceEpoch,
      ),
    );
  }
}
