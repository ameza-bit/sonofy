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

class RenamePlaylistCardOption extends StatelessWidget {
  final Playlist playlist;
  
  const RenamePlaylistCardOption({required this.playlist, super.key});

  void _showRenameDialog(BuildContext context) {
    modalView(
      context,
      title: context.tr('options.rename_playlist'),
      maxHeight: 0.40,
      children: [RenamePlaylistCardForm(playlist: playlist)],
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

class RenamePlaylistCardForm extends StatefulWidget {
  final Playlist playlist;
  
  const RenamePlaylistCardForm({required this.playlist, super.key});

  @override
  State<RenamePlaylistCardForm> createState() => _RenamePlaylistCardFormState();
}

class _RenamePlaylistCardFormState extends State<RenamePlaylistCardForm> {
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