import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class RenamePlaylistOption extends StatelessWidget {
  const RenamePlaylistOption({super.key});

  void _showRenameDialog(BuildContext context) {
    final playlistsState = context.read<PlaylistsCubit>().state;
    final selectedPlaylist = playlistsState.selectedPlaylist;

    if (selectedPlaylist == null) {
      Toast.show(context.tr('playlist.no_playlist_selected'));
      return;
    }

    modalView(
      context,
      title: context.tr('options.rename_playlist'),
      maxHeight: 0.40,
      children: [RenamePlaylistForm(playlist: selectedPlaylist)],
    );
  }

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
}

class RenamePlaylistForm extends StatefulWidget {
  const RenamePlaylistForm({required this.playlist, super.key});

  final dynamic playlist;

  @override
  State<RenamePlaylistForm> createState() => _RenamePlaylistFormState();
}

class _RenamePlaylistFormState extends State<RenamePlaylistForm> {
  late final TextEditingController _controller;

  void _renamePlaylist(String name) {
    if (name.trim().isNotEmpty && name.trim() != widget.playlist.title) {
      context.pop();
      context.read<PlaylistsCubit>().renamePlaylist(
        widget.playlist.id,
        name.trim(),
      );
      Toast.show(context.tr('playlist.playlist_renamed'));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.playlist.title);
  }

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
          onSubmitted: _renamePlaylist,
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
                onPressed: () => _renamePlaylist(_controller.text),
                child: Text(context.tr('common.save')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
