import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/data/models/playlist.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
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
        _removeFromCurrentPlaylist(context);
      },
    );
  }

  void _removeFromCurrentPlaylist(BuildContext context) {
    final playlistsCubit = context.read<PlaylistsCubit>();
    final selectedPlaylist = playlistsCubit.state.selectedPlaylist;
    
    if (selectedPlaylist == null) {
      Toast.show(context.tr('playlist.no_playlist_selected'));
      return;
    }

    // Mostrar confirmación antes de eliminar
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('common.confirmation')),
        content: Text(
          context.tr('playlist.remove_song_confirmation', namedArgs: {
            'playlist': selectedPlaylist.title,
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmRemoval(context, selectedPlaylist);
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

  void _confirmRemoval(BuildContext context, Playlist selectedPlaylist) {
    final playlistsCubit = context.read<PlaylistsCubit>();
    playlistsCubit.removeSongFromPlaylist(selectedPlaylist.id, song.id.toString());
    
    Toast.show(
      context.tr('playlist.song_removed', namedArgs: {
        'playlist': selectedPlaylist.title,
      }),
    );
  }
}