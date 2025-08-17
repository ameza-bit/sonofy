import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/constants/app_constants.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_player.dart';
import 'package:sonofy/presentation/widgets/library/song_card.dart';

class PlaylistModal extends StatelessWidget {
  const PlaylistModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: context.musicBackground,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (context) => const PlaylistModal(),
    );
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
              tag: 'lyrics_container',
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr('player.playlist'),
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
                      const SizedBox(height: 16),
                      Expanded(
                        child: BlocBuilder<PlayerCubit, PlayerState>(
                          builder: (context, state) => ListView.builder(
                            itemCount: state.playlist.length + 1,
                            itemBuilder: (context, index) {
                              if (index == state.playlist.length) {
                                return const SizedBox(
                                  height: AppSpacing.bottomSheetHeight,
                                );
                              }

                              return SongCard(
                                playlist: state.playlist,
                                song:
                                    state.playlist[(index +
                                            state.currentIndex) %
                                        state.playlist.length],
                                onTap: () => context.pop(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          resizeToAvoidBottomInset: false,
          bottomSheet: BottomPlayer(onTap: () => context.pop()),
        );
      },
    );
  }
}
