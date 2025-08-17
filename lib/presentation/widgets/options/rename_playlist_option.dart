import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class RenamePlaylistOption extends StatelessWidget {
  const RenamePlaylistOption({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightInputText,
      title: context.tr('options.rename_playlist'),
      onTap: () {
        context.pop();
        _showRenameDialog(context);
      },
    );
  }

  void _showRenameDialog(BuildContext context) {
    final playlistsState = context.read<PlaylistsCubit>().state;
    final selectedPlaylist = playlistsState.selectedPlaylist;
    
    if (selectedPlaylist == null) {
      Toast.show(context.tr('playlist.no_playlist_selected'));
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: selectedPlaylist.title,
    );
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('options.rename_playlist')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: context.tr('playlist.enter_name'),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && value.trim() != selectedPlaylist.title) {
              Navigator.of(dialogContext).pop();
              context.read<PlaylistsCubit>().renamePlaylist(
                selectedPlaylist.id,
                value.trim(),
              );
              Toast.show(context.tr('playlist.playlist_renamed'));
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
              if (name.isNotEmpty && name != selectedPlaylist.title) {
                Navigator.of(dialogContext).pop();
                context.read<PlaylistsCubit>().renamePlaylist(
                  selectedPlaylist.id,
                  name,
                );
                Toast.show(context.tr('playlist.playlist_renamed'));
              }
            },
            child: Text(context.tr('common.save')),
          ),
        ],
      ),
    );
  }
}
