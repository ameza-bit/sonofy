import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/toast.dart';
import 'package:sonofy/main.dart';
import 'package:sonofy/presentation/blocs/playlists/playlists_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';

class CreatePlaylistOption extends StatelessWidget {
  const CreatePlaylistOption({super.key});

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

  void _showCreatePlaylistDialog(BuildContext context) {
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
      builder: (modalContext) => const CreatePlaylistModal(),
    );
  }
}

class CreatePlaylistModal extends StatefulWidget {
  const CreatePlaylistModal({super.key});

  @override
  State<CreatePlaylistModal> createState() => _CreatePlaylistModalState();
}

class _CreatePlaylistModalState extends State<CreatePlaylistModal> {
  final TextEditingController _controller = TextEditingController();

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
              tag: 'create_playlist_container',
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
                              context.tr('options.create_playlist'),
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
                        onSubmitted: _createPlaylist,
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
                                  _createPlaylist(_controller.text),
                              child: Text(context.tr('common.create')),
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

  void _createPlaylist(String name) {
    if (name.trim().isNotEmpty) {
      context.pop();
      context.read<PlaylistsCubit>().createPlaylist(name.trim());
      Toast.show(context.tr('playlist.created_successfully'));
    }
  }
}
