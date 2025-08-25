import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class RemovePlaylistOption extends StatelessWidget {
  const RemovePlaylistOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightHexagonXmark,
      title: context.tr('options.remove_playlist'),
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

    modalView(
      context,
      title: context.tr('options.remove_playlist'),
      children: [RemovePlaylistSelectorForm(songId: currentSong.id.toString())],
    );
  }
}

class RemovePlaylistSelectorForm extends StatelessWidget {
  final String songId;

  const RemovePlaylistSelectorForm({required this.songId, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filtrar solo las playlists que contienen esta canción
          final playlistsWithSong = state.playlists
              .where((playlist) => playlist.containsSong(songId))
              .toList();

          if (playlistsWithSong.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.lightMusic,
                  size: 64,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('playlist.song_not_in_playlists'),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          return ListView.builder(
            itemCount: playlistsWithSong.length,
            itemBuilder: (context, index) {
              final playlist = playlistsWithSong[index];

              return ListTile(
                title: Text(playlist.title),
                subtitle: Text(
                  context.tr(
                    'playlist.songs_count',
                    namedArgs: {'count': '${playlist.songCount}'},
                  ),
                ),
                trailing: const Icon(FontAwesomeIcons.lightMinus),
                onTap: () {
                  context.pop();
                  context
                      .read<PlaylistsCubit>()
                      .removeSongFromPlaylist(playlist.id, songId);
                  Toast.show(
                    context.tr(
                      'playlist.song_removed',
                      namedArgs: {'playlist': playlist.title},
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
