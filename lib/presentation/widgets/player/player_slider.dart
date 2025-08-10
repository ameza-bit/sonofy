import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

class PlayerSlider extends StatelessWidget {
  const PlayerSlider({super.key});

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
                Text(
                  '1:24',
                  style: TextStyle(
                    color: context.musicMediumGrey,
                    fontSize: context.scaleText(12),
                  ),
                ),
                Text(
                  '3:45',
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
              child: Slider(value: 0.3, onChanged: (double value) {}),
            ),
          ],
        );
      },
    );
  }
}
