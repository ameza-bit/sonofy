import 'package:flutter/widgets.dart';
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
  String get value {
    // TODO(Armando): Agregar textos desde el archivo de localización
    return '';
  }

  IconData get icon {
    // TODO(Armando): Agregar iconos desde FontAwesome
    return FontAwesomeIcons.lightPoo;
  }
}
