import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class DeletePlaylistOption extends StatelessWidget {
  const DeletePlaylistOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightCompactDisc,
      title: context.tr('options.delete_playlist'),
      onTap: () {
        context.pop();
        _showDeleteConfirmation(context);
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final playlistsState = context.read<PlaylistsCubit>().state;
    final selectedPlaylist = playlistsState.selectedPlaylist;
    
    if (selectedPlaylist == null) {
      Toast.show(context.tr('playlist.no_playlist_selected'));
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('options.delete_playlist')),
        content: Text(
          context.tr('playlist.delete_confirmation', namedArgs: {'playlist': selectedPlaylist.title}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.tr('common.cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<PlaylistsCubit>().deletePlaylist(selectedPlaylist.id);
              Toast.show(context.tr('playlist.playlist_deleted'));
              // Volver a la pantalla anterior
              context.pop();
            },
            child: Text(context.tr('common.delete')),
          ),
        ],
      ),
    );
  }
}
