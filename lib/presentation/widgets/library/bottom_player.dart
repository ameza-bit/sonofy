import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_clipper_container.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({super.key});

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  bool _isPlaying = false;
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return BottomClipperContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Row(
              spacing: 16,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withAlpha(255 ~/ 2)],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.musicLightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Image.network(
                        'https://webcolours.ca/wp-content/uploads/2020/10/webcolours-unknown.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Different world of music',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: context.scaleText(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Manage your library settings and preferences.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: context.scaleText(12)),
                      ),
                    ],
                  ),
                ),
                CircularGradientButton(
                  size: 40,
                  elevation: 1,
                  primaryColor: _isPlaying ? primaryColor : context.musicWhite,
                  onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  child: Icon(
                    _isPlaying
                        ? FontAwesomeIcons.solidPause
                        : FontAwesomeIcons.solidPlay,
                    color: _isPlaying ? context.musicWhite : primaryColor,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
