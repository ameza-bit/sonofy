import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class PlayerControl extends StatelessWidget {
  const PlayerControl({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            BlocBuilder<PlayerCubit, PlayerState>(
              builder: (context, state) {
                IconData repeatIcon;
                Color? iconColor;

                switch (state.repeatMode) {
                  case RepeatMode.none:
                    repeatIcon = FontAwesomeIcons.lightRepeat;
                    iconColor = null;
                    break;
                  case RepeatMode.one:
                    repeatIcon = FontAwesomeIcons.lightRepeat1;
                    iconColor = primaryColor;
                    break;
                  case RepeatMode.all:
                    repeatIcon = FontAwesomeIcons.lightRepeat;
                    iconColor = primaryColor;
                    break;
                }

                return IconButton(
                  onPressed: () => context.read<PlayerCubit>().toggleRepeat(),
                  icon: Icon(repeatIcon, size: 20.0, color: iconColor),
                );
              },
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: IconButton(
                      onPressed: () =>
                          context.read<PlayerCubit>().previousSong(),
                      icon: const Icon(
                        FontAwesomeIcons.solidBackward,
                        size: 30.0,
                      ),
                    ),
                  ),
                  BlocBuilder<PlayerCubit, PlayerState>(
                    builder: (context, state) {
                      return CircularGradientButton(
                        size: 80,
                        elevation: 1,
                        primaryColor: primaryColor,
                        onPressed: () =>
                            context.read<PlayerCubit>().togglePlayPause(),
                        child: Icon(
                          state.isPlaying
                              ? FontAwesomeIcons.solidPause
                              : FontAwesomeIcons.solidPlay,
                          color: context.musicWhite,
                          size: 30,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: IconButton(
                      onPressed: () => context.read<PlayerCubit>().nextSong(),
                      icon: const Icon(
                        FontAwesomeIcons.solidForward,
                        size: 30.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // TODO(Armando): Implement sleep timer functionality
              },
              icon: Icon(
                FontAwesomeIcons.lightTimer,
                size: 20.0,
                color: primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
