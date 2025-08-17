import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/main.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/screens/settings_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/presentation/widgets/common/section_item.dart';
import 'package:sonofy/presentation/widgets/player/sleep_modal.dart';

class MusicModal extends StatelessWidget {
  const MusicModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: context.musicBackground,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.25,
        minWidth: MediaQuery.of(context).size.width,
      ),
      builder: (context) => const MusicModal(),
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
                              context.tr('player.options.title'),
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

                      BlocBuilder<PlayerCubit, PlayerState>(
                        builder: (context, state) {
                          return SectionCard(
                            title: '',
                            children: [
                              SectionItem(
                                icon: state.isSleepTimerActive
                                    ? FontAwesomeIcons.solidAlarmSnooze
                                    : FontAwesomeIcons.lightAlarmSnooze,
                                iconColor: state.isSleepTimerActive
                                    ? primaryColor
                                    : null,
                                title: context.tr('player.options.sleep'),
                                onTap: () {
                                  context.pop();
                                  SleepModal.show(
                                    navigatorKey.currentContext ?? context,
                                  );
                                },
                              ),
                              SectionItem(
                                icon: FontAwesomeIcons
                                    .lightAlbumCollectionCirclePlus,
                                title: context.tr(
                                  'player.options.add_playlist',
                                ),
                                onTap: () {
                                  context.pop();
                                  // TODO(Armando): Implement add to playlist functionality
                                },
                              ),
                              SectionItem(
                                icon: FontAwesomeIcons.lightHexagonXmark,
                                title: context.tr(
                                  'player.options.remove_playlist',
                                ),
                                onTap: () {
                                  context.pop();
                                  // TODO(Armando): Implement remove from playlist functionality
                                },
                              ),
                              SectionItem(
                                icon: FontAwesomeIcons.lightSlidersUp,
                                title: context.tr('player.options.equalizer'),
                                onTap: () {
                                  context.pop();
                                  // TODO(Armando): Implement equalizer functionality
                                },
                              ),
                              SectionItem(
                                icon: FontAwesomeIcons.lightShareNodes,
                                title: context.tr('player.options.share'),
                                onTap: () {
                                  context.pop();
                                  // TODO(Armando): Implement share functionality
                                },
                              ),
                              SectionItem(
                                icon: FontAwesomeIcons.lightGear,
                                title: context.tr('player.options.settings'),
                                onTap: () {
                                  context.pop();
                                  context.pushNamed(SettingsScreen.routeName);
                                },
                              ),
                            ],
                          );
                        },
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
