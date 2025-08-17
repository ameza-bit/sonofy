import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
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

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: context.musicBackground,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.40,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (modalContext) =>
          RenamePlaylistModal(playlist: selectedPlaylist),
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

class RenamePlaylistModal extends StatefulWidget {
  const RenamePlaylistModal({required this.playlist, super.key});

  final dynamic playlist;

  @override
  State<RenamePlaylistModal> createState() => _RenamePlaylistModalState();
}

class _RenamePlaylistModalState extends State<RenamePlaylistModal> {
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Hero(
              tag: 'rename_playlist_container',
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 24,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr('options.rename_playlist'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: context.scaleText(12)),
                            ),
                            Icon(
                              FontAwesomeIcons.lightChevronDown,
                              color: primaryColor,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
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
                              onPressed: () =>
                                  _renamePlaylist(_controller.text),
                              child: Text(context.tr('common.save')),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
