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

    modalView(
      context,
      title: context.tr('options.add_playlist'),
      children: [PlaylistSelectorForm(songId: currentSong.id.toString())],
    );
  }
}

class PlaylistSelectorForm extends StatelessWidget {
  final String songId;

  const PlaylistSelectorForm({required this.songId, super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.hasPlaylists) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            itemCount: state.playlists.length + 1,
            itemBuilder: (context, index) {
              if (index == state.playlists.length) {
                return _buildCreateButton(context);
              }

              final playlist = state.playlists[index];
              final alreadyAdded = playlist.containsSong(songId);

              return _buildPlaylistTile(context, playlist, alreadyAdded);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(context.tr('playlist.no_playlists')),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _navigateToCreatePlaylist(context),
          child: Text(context.tr('options.create_playlist')),
        ),
      ],
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: () => _navigateToCreatePlaylist(context),
        child: Text(context.tr('options.create_playlist')),
      ),
    );
  }

  Widget _buildPlaylistTile(BuildContext context, playlist, bool alreadyAdded) {
    return ListTile(
      title: Text(playlist.title),
      subtitle: Text(
        context.tr(
          'playlist.songs_count',
          namedArgs: {'count': '${playlist.songCount}'},
        ),
      ),
      trailing: alreadyAdded
          ? Icon(
              FontAwesomeIcons.lightCheck,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: alreadyAdded ? null : () => _addToPlaylist(context, playlist),
    );
  }

  void _navigateToCreatePlaylist(BuildContext context) {
    context.pop();
    _showCreatePlaylistDialog(context);
  }

  void _addToPlaylist(BuildContext context, playlist) {
    context.pop();
    context.read<PlaylistsCubit>().addSongToPlaylist(playlist.id, songId);
    Toast.show(
      context.tr(
        'playlist.song_added',
        namedArgs: {'playlist': playlist.title},
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    modalView(
      context,
      title: context.tr('options.create_playlist'),
      maxHeight: 0.4,
      children: [CreatePlaylistWithSongForm(songId: songId)],
    );
  }
}

class CreatePlaylistWithSongForm extends StatefulWidget {
  final String songId;

  const CreatePlaylistWithSongForm({required this.songId, super.key});

  @override
  State<CreatePlaylistWithSongForm> createState() =>
      _CreatePlaylistWithSongFormState();
}

class _CreatePlaylistWithSongFormState
    extends State<CreatePlaylistWithSongForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: context.tr('playlist.enter_name'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: _createPlaylistAndAddSong,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          spacing: 16,
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(context.tr('common.cancel')),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _createPlaylistAndAddSong(_controller.text),
                child: Text(context.tr('common.create')),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createPlaylistAndAddSong(String playlistName) async {
    if (playlistName.trim().isEmpty) return;
    if (!mounted) return;

    final playlistsCubit = context.read<PlaylistsCubit>();
    context.pop();

    await playlistsCubit.createPlaylist(playlistName.trim());

    // Find the newly created playlist
    final newPlaylist = playlistsCubit.state.playlists
        .where((p) => p.title == playlistName.trim())
        .firstOrNull;

    if (newPlaylist != null && mounted) {
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