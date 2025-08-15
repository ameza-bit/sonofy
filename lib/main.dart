import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/enums/language.dart';
import 'package:sonofy/core/routes/app_routes.dart';
import 'package:sonofy/core/services/preferences.dart';
import 'package:sonofy/core/themes/main_theme.dart';
import 'package:sonofy/data/repositories/player_repository_impl.dart';
import 'package:sonofy/data/repositories/settings_repository_impl.dart';
import 'package:sonofy/data/repositories/songs_repository_impl.dart';
import 'package:sonofy/domain/repositories/player_repository.dart';
import 'package:sonofy/domain/repositories/settings_repository.dart';
import 'package:sonofy/domain/repositories/songs_repository.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
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

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(
          create: (context) => SettingsCubit(settingsRepository),
        ),
        BlocProvider<SongsCubit>(
          create: (context) => SongsCubit(songsRepository),
        ),
        BlocProvider<PlayerCubit>(
          create: (context) => PlayerCubit(playerRepository),
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
