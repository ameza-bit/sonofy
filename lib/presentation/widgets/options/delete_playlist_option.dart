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

class DeletePlaylistOption extends StatelessWidget {
  const DeletePlaylistOption({super.key});

  void _showDeleteConfirmation(BuildContext context) {
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
        maxHeight: MediaQuery.of(context).size.height * 0.4,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (modalContext) =>
          DeletePlaylistModal(playlist: selectedPlaylist),
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

class DeletePlaylistModal extends StatelessWidget {
  final dynamic playlist;

  const DeletePlaylistModal({required this.playlist, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Scaffold(
          backgroundColor: context.musicBackground,
          body: SafeArea(
            child: Hero(
              tag: 'delete_playlist_container',
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
                              context.tr('options.delete_playlist'),
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
                      Text(
                        context.tr(
                          'playlist.delete_confirmation',
                          namedArgs: {'playlist': playlist.title},
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
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onError,
                              ),
                              onPressed: () {
                                context.pop();
                                context.read<PlaylistsCubit>().deletePlaylist(
                                  playlist.id,
                                );
                                Toast.show(
                                  context.tr('playlist.playlist_deleted'),
                                );
                                context.pop(); // Volver a la pantalla anterior
                              },
                              child: Text(context.tr('common.delete')),
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
