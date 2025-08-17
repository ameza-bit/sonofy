import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

enum OrderBy {
  titleAsc,
  titleDesc,
  artistAsc,
  artistDesc,
  albumAsc,
  albumDesc,
  dateAddedAsc,
  dateAddedDesc,
  durationAsc,
  durationDesc,
}

extension OrderByExtension on OrderBy {
  String get translationKey {
    switch (this) {
      case OrderBy.titleAsc:
        return 'library.order_by.title_asc';
      case OrderBy.titleDesc:
        return 'library.order_by.title_desc';
      case OrderBy.artistAsc:
        return 'library.order_by.artist_asc';
      case OrderBy.artistDesc:
        return 'library.order_by.artist_desc';
      case OrderBy.albumAsc:
        return 'library.order_by.album_asc';
      case OrderBy.albumDesc:
        return 'library.order_by.album_desc';
      case OrderBy.dateAddedAsc:
        return 'library.order_by.date_added_asc';
      case OrderBy.dateAddedDesc:
        return 'library.order_by.date_added_desc';
      case OrderBy.durationAsc:
        return 'library.order_by.duration_asc';
      case OrderBy.durationDesc:
        return 'library.order_by.duration_desc';
    }
  }

  String get value => translationKey.tr();

  IconData get icon {
    switch (this) {
      case OrderBy.titleAsc:
      case OrderBy.titleDesc:
        return FontAwesomeIcons.lightFileMusic;
      case OrderBy.artistAsc:
      case OrderBy.artistDesc:
        return FontAwesomeIcons.lightUserMusic;
      case OrderBy.albumAsc:
      case OrderBy.albumDesc:
        return FontAwesomeIcons.lightRecordVinyl;
      case OrderBy.dateAddedAsc:
      case OrderBy.dateAddedDesc:
        return FontAwesomeIcons.lightCalendarPlus;
      case OrderBy.durationAsc:
      case OrderBy.durationDesc:
        return FontAwesomeIcons.lightClock;
    }
  }

  bool get isAscending {
    switch (this) {
      case OrderBy.titleAsc:
      case OrderBy.artistAsc:
      case OrderBy.albumAsc:
      case OrderBy.dateAddedAsc:
      case OrderBy.durationAsc:
        return true;
      case OrderBy.titleDesc:
      case OrderBy.artistDesc:
      case OrderBy.albumDesc:
      case OrderBy.dateAddedDesc:
      case OrderBy.durationDesc:
        return false;
    }
  }

  List<SongModel> applySorting(List<SongModel> songs) {
    final sortedSongs = List<SongModel>.from(songs);

    sortedSongs.sort((a, b) {
      int comparison;

      switch (this) {
        case OrderBy.titleAsc:
        case OrderBy.titleDesc:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case OrderBy.artistAsc:
        case OrderBy.artistDesc:
          comparison = (a.artist ?? 'Unknown').toLowerCase().compareTo(
            (b.artist ?? 'Unknown').toLowerCase(),
          );
          break;
        case OrderBy.albumAsc:
        case OrderBy.albumDesc:
          comparison = (a.album ?? 'Unknown').toLowerCase().compareTo(
            (b.album ?? 'Unknown').toLowerCase(),
          );
          break;
        case OrderBy.dateAddedAsc:
        case OrderBy.dateAddedDesc:
          comparison = (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0);
          break;
        case OrderBy.durationAsc:
        case OrderBy.durationDesc:
          comparison = (a.duration ?? 0).compareTo(b.duration ?? 0);
          break;
      }

      return isAscending ? comparison : -comparison;
    });

    return sortedSongs;
  }

  static OrderBy fromString(String value) {
    switch (value) {
      case 'titleAsc':
        return OrderBy.titleAsc;
      case 'titleDesc':
        return OrderBy.titleDesc;
      case 'artistAsc':
        return OrderBy.artistAsc;
      case 'artistDesc':
        return OrderBy.artistDesc;
      case 'albumAsc':
        return OrderBy.albumAsc;
      case 'albumDesc':
        return OrderBy.albumDesc;
      case 'dateAddedAsc':
        return OrderBy.dateAddedAsc;
      case 'dateAddedDesc':
        return OrderBy.dateAddedDesc;
      case 'durationAsc':
        return OrderBy.durationAsc;
      case 'durationDesc':
        return OrderBy.durationDesc;
      default:
        return OrderBy.titleAsc;
    }
  }

  String get stringValue {
    switch (this) {
      case OrderBy.titleAsc:
        return 'titleAsc';
      case OrderBy.titleDesc:
        return 'titleDesc';
      case OrderBy.artistAsc:
        return 'artistAsc';
      case OrderBy.artistDesc:
        return 'artistDesc';
      case OrderBy.albumAsc:
        return 'albumAsc';
      case OrderBy.albumDesc:
        return 'albumDesc';
      case OrderBy.dateAddedAsc:
        return 'dateAddedAsc';
      case OrderBy.dateAddedDesc:
        return 'dateAddedDesc';
      case OrderBy.durationAsc:
        return 'durationAsc';
      case OrderBy.durationDesc:
        return 'durationDesc';
    }
  }
}
