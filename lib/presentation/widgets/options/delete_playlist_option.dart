import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class DeletePlaylistOption extends StatelessWidget {
  const DeletePlaylistOption({super.key});

  void _showDeleteConfirmation(BuildContext context) {
    final playlistsState = context.read<PlaylistsCubit>().state;
    final selectedPlaylist = playlistsState.selectedPlaylist;

    if (selectedPlaylist == null) {
      Toast.show(context.tr('playlist.no_playlist_selected'));
      return;
    }

    modalView(
      context,
      title: context.tr('options.delete_playlist'),
      maxHeight: 0.4,
      children: [DeletePlaylistForm(playlist: selectedPlaylist)],
    );
  }

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
}

class DeletePlaylistForm extends StatelessWidget {
  final dynamic playlist;

  const DeletePlaylistForm({required this.playlist, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        Text(
          context.tr(
            'playlist.delete_confirmation',
            namedArgs: {'name': playlist.title},
          ),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: context.scaleText(16)),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                onPressed: () {
                  context.pop();
                  context.read<PlaylistsCubit>().deletePlaylist(playlist.id);
                  Toast.show(context.tr('playlist.playlist_deleted'));
                  context.pop();
                },
                child: Text(context.tr('common.delete')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
