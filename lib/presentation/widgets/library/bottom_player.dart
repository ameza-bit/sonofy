import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_clipper_container.dart';

class BottomPlayer extends StatefulWidget {
  const BottomPlayer({this.onTap, super.key});

  final void Function()? onTap;

  @override
  State<BottomPlayer> createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_isPlaying) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1) {
            _progress = 0;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final currentSong = state.currentSong;
            final hasSelected = state.hasSelectedSong;

            final songImage = hasSelected
                ? 'assets/images/piano.png'
                : 'assets/images/placeholder.png';
            final songName = currentSong?.title ?? '';
            final artistName =
                currentSong?.artist ?? currentSong?.composer ?? '';

            return GestureDetector(
              onTap: hasSelected ? widget.onTap : null,
              child: Hero(
                tag: 'player_container',
                child: Material(
                  type: MaterialType.transparency,
                  child: BottomClipperContainer(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: SafeArea(
                      child: Row(
                        spacing: 16,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 56,
                                height: 56,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 3,
                                  backgroundColor: primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
                                  valueColor: AlwaysStoppedAnimation(
                                    primaryColor,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                radius: _isPlaying ? 24 : 20,
                                backgroundColor: context.musicLightGrey,
                                backgroundImage: AssetImage(songImage),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  songName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.scaleText(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  artistName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.scaleText(12),
                                    color: context.musicLightGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hasSelected)
                            CircularGradientButton(
                              size: 40,
                              elevation: 1,
                              primaryColor: _isPlaying
                                  ? primaryColor
                                  : context.musicWhite,
                              onPressed: () =>
                                  setState(() => _isPlaying = !_isPlaying),
                              child: Icon(
                                _isPlaying
                                    ? FontAwesomeIcons.solidPause
                                    : FontAwesomeIcons.solidPlay,
                                color: _isPlaying
                                    ? context.musicWhite
                                    : primaryColor,
                                size: 16,
                              ),
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
      },
    );
  }
}
