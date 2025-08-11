import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class PlayerControl extends StatefulWidget {
  const PlayerControl({super.key});

  @override
  State<PlayerControl> createState() => _PlayerControlState();
}

class _PlayerControlState extends State<PlayerControl> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            IconButton(
              onPressed: () => context.read<PlayerCubit>().previousSong(),
              icon: const Icon(FontAwesomeIcons.solidBackward, size: 30.0),
            ),
            CircularGradientButton(
              size: 80,
              elevation: 1,
              primaryColor: primaryColor,
              onPressed: () => setState(() => _isPlaying = !_isPlaying),
              child: Icon(
                _isPlaying
                    ? FontAwesomeIcons.solidPause
                    : FontAwesomeIcons.solidPlay,
                color: context.musicWhite,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () => context.read<PlayerCubit>().nextSong(),
              icon: const Icon(FontAwesomeIcons.solidForward, size: 30.0),
            ),
          ],
        );
      },
    );
  }
}
