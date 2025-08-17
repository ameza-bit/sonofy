import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
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

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (modalContext) =>
          RenamePlaylistModal(playlist: selectedPlaylist),
    );
  }
}

class RenamePlaylistModal extends StatefulWidget {
  final dynamic playlist;

  const RenamePlaylistModal({required this.playlist, super.key});

  @override
  State<RenamePlaylistModal> createState() => _RenamePlaylistModalState();
}

class _RenamePlaylistModalState extends State<RenamePlaylistModal> {
  late final TextEditingController _controller;

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
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(height: 24),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: context.tr('playlist.enter_name'),
                          border: const OutlineInputBorder(),
                        ),
                        autofocus: true,
                        onSubmitted: _renamePlaylist,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              child: Text(context.tr('common.cancel')),
                            ),
                          ),
                          const SizedBox(width: 16),
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
}
