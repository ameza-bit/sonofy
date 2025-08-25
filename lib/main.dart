import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/language.dart';
import 'package:sonofy/core/routes/app_routes.dart';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/core/themes/main_theme.dart';
import 'package:sonofy/data/repositories/equalizer_repository_impl.dart';
import 'package:sonofy/data/repositories/player_repository_impl.dart';
import 'package:sonofy/data/repositories/playlist_repository_impl.dart';
import 'package:sonofy/data/repositories/settings_repository_impl.dart';
import 'package:sonofy/data/repositories/songs_repository_impl.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/domain/repositories/playlist_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/domain/usecases/add_song_to_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/create_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/delete_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/get_all_playlists_usecase.dart';
import 'package:sonofy/domain/usecases/get_local_songs_usecase.dart';
import 'package:sonofy/domain/usecases/get_songs_from_folder_usecase.dart';
import 'package:sonofy/domain/usecases/remove_song_from_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/reorder_songs_in_playlist_usecase.dart';
import 'package:sonofy/domain/usecases/select_music_folder_usecase.dart';
import 'package:sonofy/domain/usecases/update_playlist_usecase.dart';
import 'package:sonofy/presentation/blocs/equalizer/equalizer_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';

final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Preferences.init();

  final SettingsRepository settingsRepository = SettingsRepositoryImpl();
  final SongsRepository songsRepository = SongsRepositoryImpl();
  final PlayerRepository playerRepository = PlayerRepositoryImpl();
  final PlaylistRepository playlistRepository = PlaylistRepositoryImpl();
  final EqualizerRepositoryImpl equalizerRepository = EqualizerRepositoryImpl();
  
  // Conectar ecualizador con reproductor para sincronización
  equalizerRepository.setPlayerRepository(playerRepository);

  // Inicializar carpeta Music en iOS
  if (songsRepository is SongsRepositoryImpl) {
    await songsRepository.initializeMusicFolder();
  }

  // Use Cases para música local - solo iOS
  SelectMusicFolderUseCase? selectMusicFolderUseCase;
  GetSongsFromFolderUseCase? getSongsFromFolderUseCase;
  GetLocalSongsUseCase? getLocalSongsUseCase;

  if (!kIsWeb && Platform.isIOS) {
    selectMusicFolderUseCase = SelectMusicFolderUseCase(songsRepository);
    getSongsFromFolderUseCase = GetSongsFromFolderUseCase(songsRepository);
    getLocalSongsUseCase = GetLocalSongsUseCase(
      songsRepository,
      settingsRepository,
    );
  }

  // Use Cases para playlists
  final GetAllPlaylistsUseCase getAllPlaylistsUseCase = GetAllPlaylistsUseCase(
    playlistRepository,
  );
  final CreatePlaylistUseCase createPlaylistUseCase = CreatePlaylistUseCase(
    playlistRepository,
  );
  final DeletePlaylistUseCase deletePlaylistUseCase = DeletePlaylistUseCase(
    playlistRepository,
  );
  final UpdatePlaylistUseCase updatePlaylistUseCase = UpdatePlaylistUseCase(
    playlistRepository,
  );
  final AddSongToPlaylistUseCase addSongToPlaylistUseCase =
      AddSongToPlaylistUseCase(playlistRepository);
  final RemoveSongFromPlaylistUseCase removeSongFromPlaylistUseCase =
      RemoveSongFromPlaylistUseCase(playlistRepository);
  final ReorderSongsInPlaylistUseCase reorderSongsInPlaylistUseCase =
      ReorderSongsInPlaylistUseCase(playlistRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(
            settingsRepository,
            selectMusicFolderUseCase,
            getSongsFromFolderUseCase,
          ),
        ),
        BlocProvider<SongsCubit>(
          create: (context) => SongsCubit(
            songsRepository,
            getLocalSongsUseCase,
            settingsRepository,
          ),
        ),
        BlocProvider<PlayerCubit>(
          create: (context) =>
              PlayerCubit(playerRepository, settingsRepository),
        ),
        BlocProvider<PlaylistsCubit>(
          create: (context) => PlaylistsCubit(
            getAllPlaylistsUseCase,
            createPlaylistUseCase,
            deletePlaylistUseCase,
            updatePlaylistUseCase,
            addSongToPlaylistUseCase,
            removeSongFromPlaylistUseCase,
            reorderSongsInPlaylistUseCase,
          ),
        ),
        BlocProvider<EqualizerCubit>(
          create: (context) => EqualizerCubit(equalizerRepository),
        ),
      ],
      child: EasyLocalization(
        supportedLocales: const [Locale('es'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('es'),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = AppRoutes.getGoRoutes(navigatorKey);

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) {
        // Solo reconstruir cuando cambian propiedades que afectan al tema o idioma
        return previous.settings.themeMode != current.settings.themeMode ||
            previous.settings.primaryColor != current.settings.primaryColor ||
            previous.settings.fontSize != current.settings.fontSize ||
            previous.settings.language != current.settings.language;
      },
      builder: (context, state) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Sonofy',
          routerConfig: routerConfig,
          theme: MainTheme.createLightTheme(state.settings.primaryColor)
              .copyWith(
                textTheme: MainTheme.createLightTheme(
                  state.settings.primaryColor,
                ).textTheme.apply(fontSizeFactor: state.settings.fontSize),
              ),
          darkTheme: MainTheme.createDarkTheme(state.settings.primaryColor)
              .copyWith(
                textTheme: MainTheme.createDarkTheme(
                  state.settings.primaryColor,
                ).textTheme.apply(fontSizeFactor: state.settings.fontSize),
              ),
          themeMode: state.settings.themeMode,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: Locale(state.settings.language.code),
        );
      },
    );
  }
}
