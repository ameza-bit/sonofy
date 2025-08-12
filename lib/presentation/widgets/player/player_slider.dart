import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/utils/duration_minutes.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';

class PlayerSlider extends StatefulWidget {
  const PlayerSlider({required this.durationMiliseconds, super.key});
  final int durationMiliseconds;

  @override
  State<PlayerSlider> createState() => _PlayerSliderState();
}

class _PlayerSliderState extends State<PlayerSlider> {
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;
        final maxDuration = widget.durationMiliseconds.toDouble();

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<int>(
              stream: context.watch<PlayerCubit>().getCurrentSongPosition(),
              builder: (context, snapshot) {
                final currentPosition = snapshot.data ?? 0;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DurationMinutes.format(currentPosition),
                      style: TextStyle(
                        color: context.musicMediumGrey,
                        fontSize: context.scaleText(12),
                      ),
                    ),
                    Text(
                      DurationMinutes.format(widget.durationMiliseconds),
                      style: TextStyle(
                        color: context.musicMediumGrey,
                        fontSize: context.scaleText(12),
                      ),
                    ),
                  ],
                );
              },
            ),
            StreamBuilder<int>(
              stream: context.watch<PlayerCubit>().getCurrentSongPosition(),
              builder: (context, snapshot) {
                final currentPosition = snapshot.data ?? 0;
                final sliderValue = _isDragging
                    ? _dragValue
                    : currentPosition.toDouble().clamp(0, maxDuration);

                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    thumbColor: primaryColor,
                    activeTrackColor: primaryColor,
                    inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                    trackHeight: 4.0,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: _isDragging ? 10.0 : 8.0,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: _isDragging ? 20.0 : 16.0,
                    ),
                  ),
                  child: Slider(
                    value: sliderValue.toDouble(),
                    divisions: widget.durationMiliseconds,
                    label: DurationMinutes.format(sliderValue.toInt()),
                    max: maxDuration,
                    onChanged: (double value) => setState(() {
                      _isDragging = true;
                      _dragValue = value;
                    }),
                    onChangeStart: (value) => setState(() {
                      _isDragging = true;
                      _dragValue = value;
                    }),
                    onChangeEnd: (value) {
                      setState(() => _isDragging = false);
                      context.read<PlayerCubit>().seekTo(
                        Duration(milliseconds: value.toInt()),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
