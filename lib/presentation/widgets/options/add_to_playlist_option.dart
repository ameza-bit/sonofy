import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class AddToPlaylistOption extends StatelessWidget {
  const AddToPlaylistOption({required this.song, super.key});

  final SongModel song;

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
    modalView(
      context,
      title: context.tr('options.add_playlist'),
      children: [PlaylistSelectorForm(songId: song.id.toString())],
    );
  }
}

class PlaylistSelectorForm extends StatelessWidget {
  final String songId;

  const PlaylistSelectorForm({required this.songId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlaylistsCubit, PlaylistsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.playlists.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(context.tr('playlist.no_playlists')),
              ),
              _buildCreatePlaylistOption(context),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...state.playlists.map((playlist) {
              final isInPlaylist = playlist.containsSong(songId);
              return ListTile(
                leading: Icon(
                  isInPlaylist
                      ? FontAwesomeIcons.solidCircleCheck
                      : FontAwesomeIcons.lightCircle,
                  color: isInPlaylist ? Colors.green : null,
                ),
                title: Text(playlist.title),
                subtitle: Text(
                  context.tr(
                    'playlist.songs_count',
                    namedArgs: {'count': playlist.songIds.length.toString()},
                  ),
                ),
                onTap: isInPlaylist
                    ? null
                    : () => _addToPlaylist(context, playlist.id),
              );
            }),
            const SizedBox(height: 16),
            _buildCreatePlaylistOption(context),
          ],
        );
      },
    );
  }

  Widget _buildCreatePlaylistOption(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => _showCreatePlaylistDialog(context),
        icon: const Icon(FontAwesomeIcons.solidPlus),
        label: Text(context.tr('options.create_playlist')),
      ),
    );
  }

  void _addToPlaylist(BuildContext context, String playlistId) {
    final playlistsCubit = context.read<PlaylistsCubit>();
    playlistsCubit.addSongToPlaylist(playlistId, songId);

    Navigator.of(context).pop();

    try {
      final playlist = playlistsCubit.state.getPlaylistById(playlistId);
      Toast.show(
        context.tr(
          'playlist.song_added',
          namedArgs: {
            'playlist': playlist?.title ?? context.tr('common.unknown'),
          },
        ),
      );
    } catch (e) {
      Toast.show(context.tr('playlist.song_added_generic'));
    }
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('options.create_playlist')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.tr('playlist.enter_name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _createPlaylistAndAddSong(context, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(context.tr('common.create')),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlaylistAndAddSong(
    BuildContext context,
    String playlistName,
  ) async {
    final playlistsCubit = context.read<PlaylistsCubit>();

    // Create the playlist
    await playlistsCubit.createPlaylist(playlistName.trim());

    // Find the newly created playlist
    final newPlaylist = playlistsCubit.state.playlists
        .where((p) => p.title == playlistName.trim())
        .last;

    // Add the song to it
    await playlistsCubit.addSongToPlaylist(newPlaylist.id, songId);

    if (context.mounted) {
      Navigator.of(context).pop();

      Toast.show(
        context.tr(
          'playlist.song_added',
          namedArgs: {'playlist': playlistName.trim()},
        ),
      );
    }
  }
}
