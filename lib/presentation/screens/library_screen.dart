import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';
import 'package:sonofy/presentation/screens/player_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';
import 'package:sonofy/presentation/widgets/library/playlist_list_section.dart';
import 'package:sonofy/presentation/widgets/library/section_title.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';
import 'package:sonofy/presentation/widgets/options/options_modal.dart';
// import 'package:sonofy/presentation/widgets/library/song_card.dart';

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
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(FontAwesomeIcons.lightMagnifyingGlass),
              onPressed: () {},
            ),
            const SizedBox(width: 12),
            const Spacer(),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.lightEllipsisStrokeVertical,
                size: 20.0,
              ),
              onPressed: () => OptionsModal.library(context),
            ),
            const SizedBox(width: 12),
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
              } else if (state.songs.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 16.0,
                          children: [
                            Icon(
                              FontAwesomeIcons.lightMusic,
                              size: 64,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            Text(
                              context.tr('library.empty'),
                              style: TextStyle(fontSize: context.scaleText(18)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.bottomSheetHeight),
                  ],
                );
              }

              final orderedSongs = state.songs;
              return ListView.builder(
                itemCount: orderedSongs.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Título
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PlaylistListSection(),
                        SectionTitle(
                          title: context.tr('library.title'),
                          subtitle: context.tr(
                            'playlist.songs_count',
                            namedArgs: {'count': '${orderedSongs.length}'},
                          ),
                        ),
                      ],
                    );
                  } else if (index == orderedSongs.length + 1) {
                    // Espacio final
                    return const SizedBox(height: AppSpacing.bottomSheetHeight);
                  } else {
                    // Canción
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SongCard(
                        playlist: orderedSongs,
                        song: orderedSongs[index - 1],
                        onTap: () => context.pushNamed(PlayerScreen.routeName),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        resizeToAvoidBottomInset: false,
        bottomSheet: BottomPlayer(
          onTap: () => context.pushNamed(PlayerScreen.routeName),
        ),
      ),
    );
  }
}
