import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';
import 'package:sonofy/data/models/playlist.dart';

class DeletePlaylistCardOption extends StatelessWidget {
  final Playlist playlist;
  
  const DeletePlaylistCardOption({required this.playlist, super.key});

  void _showDeleteConfirmation(BuildContext context) {
    modalView(
      context,
      title: context.tr('options.delete_playlist'),
      maxHeight: 0.4,
      children: [DeletePlaylistCardForm(playlist: playlist)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightTrash,
      title: context.tr('options.delete_playlist'),
      onTap: () {
        context.pop();
        _showDeleteConfirmation(context);
      },
    );
  }
}

class DeletePlaylistCardForm extends StatelessWidget {
  final Playlist playlist;
  
  const DeletePlaylistCardForm({required this.playlist, super.key});

  void _deletePlaylist(BuildContext context) {
    context.pop();
    context.read<PlaylistsCubit>().deletePlaylist(playlist.id);
    Toast.show(context.tr('playlist.playlist_deleted'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 24,
      children: [
        Text(
          context.tr('playlist.delete_confirmation', namedArgs: {'name': playlist.title}),
          textAlign: TextAlign.center,
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
                onPressed: () => _deletePlaylist(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text(
                  context.tr('common.delete'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}