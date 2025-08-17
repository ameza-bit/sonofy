import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
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

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('options.add_playlist')),
        content: SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<PlaylistsCubit, PlaylistsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!state.hasPlaylists) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(context.tr('playlist.no_playlists')),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _showCreatePlaylistDialog(context, currentSong.id.toString());
                      },
                      child: Text(context.tr('options.create_playlist')),
                    ),
                  ],
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: state.playlists.length,
                itemBuilder: (context, index) {
                  final playlist = state.playlists[index];
                  final alreadyAdded = playlist.containsSong(currentSong.id.toString());
                  
                  return ListTile(
                    title: Text(playlist.title),
                    subtitle: Text(context.tr('playlist.songs_count', namedArgs: {'count': '${playlist.songCount}'})),
                    trailing: alreadyAdded 
                        ? Icon(FontAwesomeIcons.lightCheck, color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: alreadyAdded ? null : () {
                      Navigator.of(dialogContext).pop();
                      context.read<PlaylistsCubit>().addSongToPlaylist(
                        playlist.id,
                        currentSong.id.toString(),
                      );
                      Toast.show(context.tr('playlist.song_added', namedArgs: {'playlist': playlist.title}));
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showCreatePlaylistDialog(context, currentSong.id.toString());
            },
            child: Text(context.tr('options.create_playlist')),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, String songId) {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('options.create_playlist')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.tr('playlist.enter_name'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(dialogContext).pop();
              _createPlaylistAndAddSong(context, value.trim(), songId);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop();
                _createPlaylistAndAddSong(context, name, songId);
              }
            },
            child: Text(context.tr('common.create')),
          ),
        ],
      ),
    );
  }

  Future<void> _createPlaylistAndAddSong(BuildContext context, String playlistName, String songId) async {
    final playlistsCubit = context.read<PlaylistsCubit>();
    await playlistsCubit.createPlaylist(playlistName);
    
    // Encontrar la playlist recién creada
    final newPlaylist = playlistsCubit.state.playlists
        .where((p) => p.title == playlistName)
        .isNotEmpty ? playlistsCubit.state.playlists
        .where((p) => p.title == playlistName)
        .first : null;
    
    if (newPlaylist != null) {
      await playlistsCubit.addSongToPlaylist(newPlaylist.id, songId);
      Toast.show(context.tr('playlist.created_and_song_added', namedArgs: {'playlist': playlistName}));
    }
  }
}
