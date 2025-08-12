import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/duration_minutes.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

class PlayerSlider extends StatelessWidget {
  const PlayerSlider({required this.durationMiliseconds, super.key});
  final int durationMiliseconds;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder(
                  stream: context.watch<PlayerCubit>().getCurrentSongPosition(),
                  builder: (context, asyncSnapshot) => Text(
                    DurationMinutes.format(asyncSnapshot.data ?? 0),
                    style: TextStyle(
                      color: context.musicMediumGrey,
                      fontSize: context.scaleText(12),
                    ),
                  ),
                ),
                Text(
                  DurationMinutes.format(durationMiliseconds),
                  style: TextStyle(
                    color: context.musicMediumGrey,
                    fontSize: context.scaleText(12),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                thumbColor: primaryColor,
                activeTrackColor: primaryColor,
                inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                trackHeight: 4.0,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 8.0,
                ),
              ),
              child: StreamBuilder(
                stream: context.watch<PlayerCubit>().getCurrentSongPosition(),
                builder: (context, asyncSnapshot) {
                  return Slider(
                    value: asyncSnapshot.data?.toDouble() ?? 0,
                    max: durationMiliseconds.toDouble(),
                    onChanged: (double value) {},
                    onChangeEnd: (value) => context.read<PlayerCubit>().seekTo(
                      Duration(milliseconds: value.toInt()),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
