import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/main.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/views/modal_view.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class CreatePlaylistOption extends StatelessWidget {
  const CreatePlaylistOption({super.key});

  void _showCreatePlaylistDialog(BuildContext context) {
    modalView(
      context,
      title: context.tr('options.create_playlist'),
      maxHeight: 0.40,
      children: [const CreatePlaylistForm()],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SectionItem(
      icon: FontAwesomeIcons.lightAlbumCollectionCirclePlus,
      title: context.tr('options.create_playlist'),
      onTap: () {
        context.pop();
        _showCreatePlaylistDialog(navigatorKey.currentContext!);
      },
    );
  }
}

class CreatePlaylistForm extends StatefulWidget {
  const CreatePlaylistForm({super.key});

  @override
  State<CreatePlaylistForm> createState() => _CreatePlaylistFormState();
}

class _CreatePlaylistFormState extends State<CreatePlaylistForm> {
  final TextEditingController _controller = TextEditingController();

  void _createPlaylist(String name) {
    if (name.trim().isNotEmpty) {
      context.pop();
      context.read<PlaylistsCubit>().createPlaylist(name.trim());
      Toast.show(context.tr('playlist.created_successfully'));
    }
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
          onSubmitted: _createPlaylist,
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
                onPressed: () => _createPlaylist(_controller.text),
                child: Text(context.tr('common.create')),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
