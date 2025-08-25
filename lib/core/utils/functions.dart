import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Obtiene o crea la carpeta Music en el directorio de documentos de la app (solo iOS)
Future<String> getMusicFolderPath() async {
  try {
    if (!kIsWeb && Platform.isIOS) {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String musicFolderPath = path.join(appDocDir.path, 'Music');

      // Crear la carpeta si no existe
      final Directory musicDir = Directory(musicFolderPath);
      if (!musicDir.existsSync()) {
        await musicDir.create(recursive: true);
        if (kDebugMode) {
          print('Created Music folder at: $musicFolderPath');
        }
      }

      return musicFolderPath;
    }
    return '';
  } catch (e) {
    if (kDebugMode) {
      print('Error getting Music folder path: $e');
    }
    return '';
  }
}
