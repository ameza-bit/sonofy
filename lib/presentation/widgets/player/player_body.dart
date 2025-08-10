import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/widgets/player/player_control.dart';
import 'package:sonofy/presentation/widgets/player/player_slider.dart';

class PlayerBody extends StatelessWidget {
  const PlayerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PlayerSlider(),
        const SizedBox(height: 16),
        Text(
          'Different world of music',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.musicDeepBlack,
            fontSize: context.scaleText(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Manage your library settings and preferences.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.scaleText(12),
            color: context.musicDarkGrey,
          ),
        ),
        const SizedBox(height: 30),
        const PlayerControl(),
      ],
    );
  }
}
