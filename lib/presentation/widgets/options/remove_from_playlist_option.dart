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

class RemoveFromPlaylistOption extends StatelessWidget {
  const RemoveFromPlaylistOption({
    required this.song,
    super.key,
  });

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightCircleMinus,
      title: context.tr('options.remove_playlist'),
      onTap: () {
        context.pop();
        _showPlaylistSelector(context);
      },
    );
  }

  void _showPlaylistSelector(BuildContext context) {
    modalView(
      context,
      title: context.tr('options.remove_playlist'),
      children: [PlaylistRemovalForm(songId: song.id.toString())],
    );
  }
}

class PlaylistRemovalForm extends StatelessWidget {
  final String songId;

  const PlaylistRemovalForm({required this.songId, super.key});

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

        final playlistsWithSong = state.playlists
            .where((playlist) => playlist.containsSong(songId))
            .toList();

        if (playlistsWithSong.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              context.tr('playlist.song_not_in_playlists'),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: playlistsWithSong.map((playlist) {
            return ListTile(
              leading: Icon(
                FontAwesomeIcons.lightCircleMinus,
                color: Colors.red,
              ),
              title: Text(playlist.title),
              subtitle: Text(
                context.tr('playlist.songs_count', namedArgs: {
                  'count': playlist.songIds.length.toString(),
                }),
              ),
              onTap: () => _removeFromPlaylist(context, playlist.id, playlist.title),
            );
          }).toList(),
        );
      },
    );
  }

  void _removeFromPlaylist(BuildContext context, String playlistId, String playlistTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('common.confirmation')),
        content: Text(
          context.tr('playlist.remove_song_confirmation', namedArgs: {
            'playlist': playlistTitle,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              _confirmRemoval(context, playlistId, playlistTitle);
              Navigator.pop(context);
            },
            child: Text(
              context.tr('common.delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmRemoval(BuildContext context, String playlistId, String playlistTitle) {
    context.read<PlaylistsCubit>().removeSongFromPlaylist(playlistId, songId);
    
    Navigator.of(context).pop();
    
    Toast.show(
      context.tr('playlist.song_removed', namedArgs: {
        'playlist': playlistTitle,
      }),
    );
  }
}