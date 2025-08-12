import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/core/utils/duration_minutes.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/screens/player_screen.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';

class SongCard extends StatelessWidget {
  const SongCard({required this.playlist, required this.song, super.key});
  final List<SongModel> playlist;
  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return InkWell(
          onTap: () {
            context.read<PlayerCubit>().setPlayingSong(playlist, song);
            context.pushNamed(PlayerScreen.routeName);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                spacing: 12,
                children: [
                  BlocBuilder<PlayerCubit, PlayerState>(
                    builder: (context, state) {
                      final bool isPlaying =
                          state.isPlaying && state.currentSong?.id == song.id;
                      return CircularGradientButton(
                        size: 48,
                        elevation: 1,
                        primaryColor: isPlaying
                            ? primaryColor
                            : context.musicWhite,
                        onPressed: () {
                          if (state.currentSong?.id == song.id) {
                            context.read<PlayerCubit>().togglePlayPause();
                          } else {
                            context.read<PlayerCubit>().setPlayingSong(
                              playlist,
                              song,
                            );
                          }
                        },
                        child: Icon(
                          isPlaying
                              ? FontAwesomeIcons.solidPause
                              : FontAwesomeIcons.solidPlay,
                          color: isPlaying ? context.musicWhite : primaryColor,
                          size: 20,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: context.scaleText(16),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          song.artist ?? song.composer ?? 'Desconocido',
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
                  Text(
                    DurationMinutes.format(song.duration ?? 0),
                    style: TextStyle(
                      fontSize: context.scaleText(12),
                      color: context.musicLightGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
