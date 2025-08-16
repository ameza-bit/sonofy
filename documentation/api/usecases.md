# Use Cases - Lógica de Negocio

## 📖 Visión General

Los Use Cases en Sonofy implementan la lógica de negocio específica de la aplicación siguiendo los principios de Clean Architecture. Cada Use Case encapsula una operación específica del dominio y actúa como intermediario entre la capa de presentación y los repositorios.

## 🎯 Principios de Diseño

### Single Responsibility
Cada Use Case tiene una única responsabilidad específica.

### Independencia de Framework
Los Use Cases no dependen de Flutter ni de ningún framework específico.

### Testabilidad
Toda la lógica de negocio puede ser probada de forma aislada.

### Reutilización
Los Use Cases pueden ser utilizados por múltiples componentes de presentación.

## 📁 Estructura de Use Cases

```
domain/usecases/
├── get_local_songs_usecase.dart      # Obtener canciones de carpeta local
├── get_songs_from_folder_usecase.dart # Escanear archivos MP3 en carpeta
└── select_music_folder_usecase.dart   # Seleccionar carpeta de música
```

## 🎵 GetLocalSongsUseCase

### Responsabilidad
Obtiene canciones MP3 de la carpeta local configurada y las convierte a objetos SongModel con metadatos estimados.

### Implementación

```dart
class GetLocalSongsUseCase {
  final SongsRepository _songsRepository;
  final SettingsRepository _settingsRepository;

  GetLocalSongsUseCase(this._songsRepository, this._settingsRepository);

  Future<List<SongModel>> call() async {
    try {
      final settings = _settingsRepository.getSettings();
      final localPath = settings.localMusicPath;
      
      if (localPath == null || localPath.isEmpty) {
        return [];
      }
      
      final files = await _songsRepository.getSongsFromFolder(localPath);
      
      // Convert files to SongModel using utility
      return Mp3FileConverter.convertFilesToSongModels(files);
    } catch (e) {
      return [];
    }
  }
}
```

### Flujo de Ejecución

1. **Obtener configuraciones**: Lee la ruta de música local desde las configuraciones
2. **Validar ruta**: Verifica que existe una ruta configurada
3. **Escanear archivos**: Obtiene lista de archivos MP3 de la carpeta
4. **Convertir datos**: Transforma archivos en objetos SongModel con metadatos
5. **Retornar resultado**: Lista de canciones con duración estimada

### Casos de Uso

```dart
// En SongsCubit
final localSongs = await _getLocalSongsUseCase();

// En SettingsCubit (después de seleccionar carpeta)
final mp3Files = await settingsCubit.getMp3FilesFromCurrentFolder();
```

### Manejo de Errores

- **Carpeta no configurada**: Retorna lista vacía
- **Carpeta inexistente**: Retorna lista vacía
- **Sin permisos**: Retorna lista vacía
- **Errores de E/O**: Retorna lista vacía

## 📂 GetSongsFromFolderUseCase

### Responsabilidad
Escanea una carpeta específica de forma recursiva para encontrar todos los archivos MP3.

### Implementación

```dart
class GetSongsFromFolderUseCase {
  final SongsRepository _songsRepository;

  GetSongsFromFolderUseCase(this._songsRepository);

  Future<List<File>> call(String folderPath) async {
    return _songsRepository.getSongsFromFolder(folderPath);
  }
}
```

### Características

- **Búsqueda recursiva**: Explora subcarpetas automáticamente
- **Filtrado por extensión**: Solo archivos .mp3
- **Manejo de errores**: Retorna lista vacía en caso de problemas
- **Validación de ruta**: Verifica existencia del directorio

### Casos de Uso

```dart
// En SettingsCubit para obtener archivos de carpeta específica
final files = await _getSongsFromFolderUseCase(selectedPath);
print('Found ${files.length} MP3 files');
```

## 🗂️ SelectMusicFolderUseCase

### Responsabilidad
Permite al usuario seleccionar una carpeta del sistema de archivos para importar música.

### Implementación

```dart
class SelectMusicFolderUseCase {
  final SongsRepository _songsRepository;

  SelectMusicFolderUseCase(this._songsRepository);

  Future<String?> call() async {
    return _songsRepository.selectMusicFolder();
  }
}
```

### Comportamiento por Plataforma

#### iOS
- Utiliza el selector nativo de carpetas
- Requiere permisos de acceso a documentos
- Soporta selección de carpetas iCloud

#### Android
- Usa el selector de archivos del sistema
- Compatible con Storage Access Framework
- Maneja permisos de almacenamiento automáticamente

### Casos de Uso

```dart
// En SettingsCubit para seleccionar nueva carpeta
final selectedPath = await _selectMusicFolderUseCase();
if (selectedPath != null) {
  // Actualizar configuraciones
  final newSettings = state.settings.copyWith(localMusicPath: selectedPath);
  _updateSetting(newSettings);
}
```

## 🛠️ Utility: Mp3FileConverter

### Responsabilidad
Convierte archivos MP3 en objetos SongModel con metadatos estimados.

### Implementación

```dart
class Mp3FileConverter {
  /// Converts a list of MP3 files to SongModel objects with estimated duration
  static List<SongModel> convertFilesToSongModels(List<File> files) {
    return files.map(_convertFileToSongModel).toList();
  }

  /// Converts a single MP3 file to SongModel with estimated duration
  static SongModel _convertFileToSongModel(File file) {
    final fileName = file.path.split('/').last;
    final title = fileName.split('.').first;
    
    // Extract basic information from filename
    final String artistName = _extractArtistFromFileName(fileName);
    const String albumName = 'Local Files';
    final String songTitle = title;
    
    // Calculate estimated duration based on file size
    final int durationMs = _estimateDurationFromFileSize(file.lengthSync());

    return SongModel({
      '_id': file.hashCode,
      '_data': file.path,
      '_display_name': fileName,
      '_display_name_wo_ext': title,
      'file_extension': fileName.split('.').last,
      'is_music': true,
      'title': songTitle,
      'artist': artistName,
      'album': albumName,
      '_size': file.lengthSync(),
      'duration': durationMs,
      'album_id': albumName.hashCode,
      'artist_id': artistName.hashCode,
      'date_added': DateTime.now().millisecondsSinceEpoch,
      'date_modified': file.lastModifiedSync().millisecondsSinceEpoch,
    });
  }
}
```

### Funcionalidades

#### Extracción de Artista
Soporta formatos comunes de nomenclatura:
- `"Artista - Canción.mp3"` → Artista: "Artista"
- `"Artista_Canción.mp3"` → Artista: "Artista"
- `"Canción.mp3"` → Artista: "Unknown Artist"

#### Estimación de Duración
Calcula duración aproximada basada en tamaño del archivo:
- **Asunción**: MP3 a 128kbps ≈ 16KB/s
- **Fórmula**: `duración = tamaño_archivo / 16000 segundos`
- **Precisión**: ~90% para MP3 128kbps, menor para otros bitrates

```dart
static int _estimateDurationFromFileSize(int fileSizeBytes) {
  const int averageBytesPerSecond = 16000; // 128kbps / 8 = 16KB/s
  final int estimatedSeconds = fileSizeBytes ~/ averageBytesPerSecond;
  return estimatedSeconds * 1000; // Convert to milliseconds
}
```

## 🔄 Integración con Presentation Layer

### En SongsCubit

```dart
class SongsCubit extends Cubit<SongsState> {
  final SongsRepository _songsRepository;
  final GetLocalSongsUseCase _getLocalSongsUseCase;

  SongsCubit(
    this._songsRepository,
    this._getLocalSongsUseCase,
  ) : super(SongsState.initial()) {
    loadAllSongs();
  }

  Future<void> loadAllSongs() async {
    try {
      emit(state.copyWith(isLoading: true));

      // Obtener canciones del dispositivo y locales por separado
      final deviceSongs = await _songsRepository.getSongsFromDevice();
      final localSongs = await _getLocalSongsUseCase();
      
      // Combinar todas las canciones
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
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> refreshLocalSongs() async {
    await loadLocalSongs();
  }
}
```

### En SettingsCubit

```dart
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  final SelectMusicFolderUseCase _selectMusicFolderUseCase;
  final GetSongsFromFolderUseCase _getSongsFromFolderUseCase;

  SettingsCubit(
    this._settingsRepository,
    this._selectMusicFolderUseCase,
    this._getSongsFromFolderUseCase,
  ) : super(SettingsState.initial()) {
    _loadSettings();
  }

  Future<bool> selectAndSetMusicFolder() async {
    emit(state.copyWith(isLoading: true));
    try {
      final String? selectedPath = await _selectMusicFolderUseCase();
      if (selectedPath != null) {
        final List<File> mp3Files = await _getSongsFromFolderUseCase(selectedPath);
        final newSettings = state.settings.copyWith(localMusicPath: selectedPath);
        _updateSetting(newSettings);
        emit(state.copyWith(isLoading: false));
        return mp3Files.isNotEmpty;
      } else {
        emit(state.copyWith(isLoading: false));
        return false;
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
      return false;
    }
  }
}
```

## 🧪 Testing de Use Cases

### Estructura de Test

```dart
group('GetLocalSongsUseCase Tests', () {
  late MockSongsRepository mockSongsRepository;
  late MockSettingsRepository mockSettingsRepository;
  late GetLocalSongsUseCase useCase;

  setUp(() {
    mockSongsRepository = MockSongsRepository();
    mockSettingsRepository = MockSettingsRepository();
    useCase = GetLocalSongsUseCase(mockSongsRepository, mockSettingsRepository);
  });

  test('should return empty list when no local path configured', () async {
    // Arrange
    final settings = Settings(localMusicPath: null);
    when(() => mockSettingsRepository.getSettings()).thenReturn(settings);

    // Act
    final result = await useCase();

    // Assert
    expect(result, isEmpty);
    verifyNever(() => mockSongsRepository.getSongsFromFolder(any()));
  });

  test('should return songs when local path configured', () async {
    // Arrange
    const localPath = '/test/music';
    final settings = Settings(localMusicPath: localPath);
    final mockFiles = [File('/test/music/song1.mp3'), File('/test/music/song2.mp3')];
    
    when(() => mockSettingsRepository.getSettings()).thenReturn(settings);
    when(() => mockSongsRepository.getSongsFromFolder(localPath))
        .thenAnswer((_) async => mockFiles);

    // Act
    final result = await useCase();

    // Assert
    expect(result, hasLength(2));
    expect(result.first.title, 'song1');
    expect(result.first.artist, 'Unknown Artist');
    expect(result.first.album, 'Local Files');
    expect(result.first.duration, isA<int>());
  });
});
```

### Mocks Necesarios

```dart
class MockSongsRepository extends Mock implements SongsRepository {}
class MockSettingsRepository extends Mock implements SettingsRepository {}
```

## 🔮 Extensiones Futuras

### Metadatos Avanzados
- **Tag reading**: Lectura real de metadatos ID3
- **Cover art**: Extracción de carátulas embebidas
- **Lyrics**: Soporte para letras embebidas

### Optimizaciones
- **Caching**: Cache de metadatos calculados
- **Background processing**: Procesamiento en segundo plano
- **Incremental updates**: Actualizaciones incrementales

### Nuevos Use Cases
- **Playlist management**: Gestión de playlists locales
- **Music organization**: Organización automática por metadatos
- **Duplicate detection**: Detección de canciones duplicadas

Los Use Cases proporcionan una capa robusta de lógica de negocio que mantiene la separación de responsabilidades y facilita el testing y mantenimiento del código.