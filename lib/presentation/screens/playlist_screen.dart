import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/blocs/songs/songs_cubit.dart';
import 'package:sonofy/presentation/blocs/songs/songs_state.dart';
import 'package:sonofy/presentation/screens/library_screen.dart';
import 'package:sonofy/presentation/screens/player_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';
import 'package:sonofy/presentation/widgets/options/options_modal.dart';

class PlaylistScreen extends StatefulWidget {
  static const String routeName = 'playlist';
  const PlaylistScreen({required this.playlistId, super.key});
  final String playlistId;

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();
    // Asegurar que tenemos una playlist válida al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playlistsCubit = context.read<PlaylistsCubit>();
      final playlistsState = playlistsCubit.state;

      // Verificar si la playlist existe
      final playlist = playlistsState.getPlaylistById(widget.playlistId);
      if (playlist == null && playlistsState.hasPlaylists) {
        // Si la playlist no existe, volvemos a Library Screen
        context.goNamed(LibraryScreen.routeName);
      } else if (playlist != null) {
        // Seleccionar la playlist actual para mantener consistencia en el estado
        playlistsCubit.selectPlaylist(widget.playlistId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, playlistsState) {
        final selectedPlaylist = playlistsState.getPlaylistById(
          widget.playlistId,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              selectedPlaylist?.title ?? context.tr('playlist.title'),
              style: TextStyle(
                fontSize: context.scaleText(24),
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.lightEllipsisStrokeVertical,
                  size: 20.0,
                ),
                onPressed: OptionsModal(context).playlist,
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: selectedPlaylist == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(child: Text('No playlist selected')),
                      ),
                      SizedBox(height: AppSpacing.bottomSheetHeight),
                    ],
                  )
                : BlocBuilder<SongsCubit, SongsState>(
                    builder: (context, songsState) {
                      if (songsState.isLoading) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            SizedBox(height: AppSpacing.bottomSheetHeight),
                          ],
                        );
                      }

                      // Filtrar canciones que están en la playlist
                      // Convertir song.id (int) a String para comparar con songIds almacenados
                      final playlistSongs = songsState.songs.where((song) {
                        final songIdAsString = song.id.toString();
                        return selectedPlaylist.songIds.contains(
                          songIdAsString,
                        );
                      }).toList();

                      if (playlistSongs.isEmpty) {
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
                                      context.tr('playlist.empty'),
                                      style: TextStyle(
                                        fontSize: context.scaleText(18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: AppSpacing.bottomSheetHeight,
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        itemCount: playlistSongs.length + 1,
                        itemBuilder: (context, index) {
                          if (index == playlistSongs.length) {
                            return const SizedBox(
                              height: AppSpacing.bottomSheetHeight,
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: SongCard(
                                playlist: playlistSongs,
                                song: playlistSongs[index],
                                onTap: () =>
                                    context.pushNamed(PlayerScreen.routeName),
                                onLongPress: () =>
                                    OptionsModal(context).songPlaylistContext(
                                      playlistSongs[index],
                                      playlistSongs,
                                    ),
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
        );
      },
    );
  }
}
