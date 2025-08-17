import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class AddPlaylistOption extends StatelessWidget {
  const AddPlaylistOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightAlbumCirclePlus,
      title: context.tr('options.add_playlist'),
      onTap: () {
        context.pop();
        _showPlaylistSelector(context);
      },
    );
  }

  void _showPlaylistSelector(BuildContext context) {
    final playerState = context.read<PlayerCubit>().state;
    if (!playerState.hasSelectedSong) {
      Toast.show(context.tr('player.no_song_selected'));
      return;
    }

    final currentSong = playerState.currentSong!;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (modalContext) =>
          PlaylistSelectorModal(songId: currentSong.id.toString()),
    );
  }
}

class PlaylistSelectorModal extends StatelessWidget {
  final String songId;

  const PlaylistSelectorModal({required this.songId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final primaryColor = settingsState.settings.primaryColor;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Hero(
              tag: 'playlist_selector_container',
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr('options.add_playlist'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: context.scaleText(12)),
                            ),
                            Icon(
                              FontAwesomeIcons.lightChevronDown,
                              color: primaryColor,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!state.hasPlaylists) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(context.tr('playlist.no_playlists')),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.pop();
                                      _showCreatePlaylistDialog(context);
                                    },
                                    child: Text(
                                      context.tr('options.create_playlist'),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return ListView.builder(
                              itemCount: state.playlists.length + 1,
                              itemBuilder: (context, index) {
                                if (index == state.playlists.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.pop();
                                        _showCreatePlaylistDialog(context);
                                      },
                                      child: Text(
                                        context.tr('options.create_playlist'),
                                      ),
                                    ),
                                  );
                                }

                                final playlist = state.playlists[index];
                                final alreadyAdded = playlist.containsSong(
                                  songId,
                                );

                                return ListTile(
                                  title: Text(playlist.title),
                                  subtitle: Text(
                                    context.tr(
                                      'playlist.songs_count',
                                      namedArgs: {
                                        'count': '${playlist.songCount}',
                                      },
                                    ),
                                  ),
                                  trailing: alreadyAdded
                                      ? Icon(
                                          FontAwesomeIcons.lightCheck,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        )
                                      : null,
                                  onTap: alreadyAdded
                                      ? null
                                      : () {
                                          context.pop();
                                          context
                                              .read<PlaylistsCubit>()
                                              .addSongToPlaylist(
                                                playlist.id,
                                                songId,
                                              );
                                          Toast.show(
                                            context.tr(
                                              'playlist.song_added',
                                              namedArgs: {
                                                'playlist': playlist.title,
                                              },
                                            ),
                                          );
                                        },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (modalContext) => CreatePlaylistWithSongModal(songId: songId),
    );
  }
}

class CreatePlaylistWithSongModal extends StatefulWidget {
  final String songId;

  const CreatePlaylistWithSongModal({required this.songId, super.key});

  @override
  State<CreatePlaylistWithSongModal> createState() =>
      _CreatePlaylistWithSongModalState();
}

class _CreatePlaylistWithSongModalState
    extends State<CreatePlaylistWithSongModal> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Hero(
              tag: 'create_playlist_with_song_container',
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr('options.create_playlist'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: context.scaleText(12)),
                            ),
                            Icon(
                              FontAwesomeIcons.lightChevronDown,
                              color: primaryColor,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: context.tr('playlist.enter_name'),
                          border: const OutlineInputBorder(),
                        ),
                        autofocus: true,
                        onSubmitted: _createPlaylistAndAddSong,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: Text(context.tr('common.cancel')),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _createPlaylistAndAddSong(_controller.text),
                              child: Text(context.tr('common.create')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createPlaylistAndAddSong(String playlistName) async {
    if (playlistName.trim().isEmpty) return;

    if (!mounted) return;

    final playlistsCubit = context.read<PlaylistsCubit>();
    context.pop();

    await playlistsCubit.createPlaylist(playlistName.trim());

    // Encontrar la playlist recién creada
    final newPlaylist =
        playlistsCubit.state.playlists
            .where((p) => p.title == playlistName.trim())
            .isNotEmpty
        ? playlistsCubit.state.playlists
              .where((p) => p.title == playlistName.trim())
              .first
        : null;

    if (newPlaylist != null) {
      await playlistsCubit.addSongToPlaylist(newPlaylist.id, widget.songId);
      if (mounted) {
        Toast.show(
          context.tr(
            'playlist.created_and_song_added',
            namedArgs: {'playlist': playlistName.trim()},
          ),
        );
      }
    }
  }
}
