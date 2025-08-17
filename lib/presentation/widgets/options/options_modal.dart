import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/common/section_card.dart';
import 'package:sonofy/presentation/widgets/options/add_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/equalizer_option.dart';
import 'package:sonofy/presentation/widgets/options/remove_playlist_option.dart';
import 'package:sonofy/presentation/widgets/options/settings_option.dart';
import 'package:sonofy/presentation/widgets/options/share_option.dart';
import 'package:sonofy/presentation/widgets/options/sleep_option.dart';

class OptionsModal extends StatelessWidget {
  const OptionsModal({required this.options, super.key});

  final List<Widget> options;

  static void _show(BuildContext context, List<Widget> options) {
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
      builder: (context) => OptionsModal(options: options),
    );
  }

  static void library(BuildContext context) => _show(context, [
    const SleepOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  static void playlist(BuildContext context) => _show(context, [
    const SleepOption(),
    const EqualizerOption(),
    const SettingsOption(),
  ]);

  static void player(BuildContext context) => _show(context, [
    const SleepOption(),
    const AddPlaylistOption(),
    const RemovePlaylistOption(),
    const EqualizerOption(),
    const ShareOption(),
    const SettingsOption(),
  ]);

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
                              context.tr('options.title'),
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
                      SectionCard(title: '', children: options),
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
