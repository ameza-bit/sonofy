import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';
import 'package:sonofy/presentation/screens/player_screen.dart';
import 'package:sonofy/presentation/screens/settings_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';

class LibraryScreen extends StatelessWidget {
  static const String routeName = 'library';
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.lightMagnifyingGlass),
              onPressed: () {},
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(FontAwesomeIcons.lightGear),
              onPressed: () => context.pushNamed(SettingsScreen.routeName),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<SongsCubit, SongsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Center(child: CircularProgressIndicator())),
                    SizedBox(height: AppSpacing.bottomSheetHeight),
                  ],
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: state.songs.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Título
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('library.title'),
                          style: TextStyle(
                            fontSize: context.scaleText(24),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    );
                  } else if (index == state.songs.length + 1) {
                    // Espacio final
                    return const SizedBox(height: AppSpacing.bottomSheetHeight);
                  } else {
                    // Canción
                    return SongCard(
                      playlist: state.songs,
                      song: state.songs[index - 1],
                    );
                  }
                },
              );
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        bottomSheet: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(height: 80, color: Theme.of(context).cardColor),
            ),
            BottomPlayer(
              onTap: () => context.pushNamed(PlayerScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
