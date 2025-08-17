import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/core/themes/gradient_helpers.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/blocs/settings/settings_cubit.dart';
import 'package:sonofy/presentation/blocs/settings/settings_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/player_clipper_container.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({this.onTap, super.key});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final primaryColor = state.settings.primaryColor;

        return BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final currentSong = state.currentSong;
            final hasSelected = state.hasSelectedSong;
            final isPlaying = state.isPlaying;

            final songName = currentSong?.title ?? '';
            final artistName =
                currentSong?.artist ?? currentSong?.composer ?? '';

            return GestureDetector(
              onTap: hasSelected ? onTap : null,
              child: Hero(
                tag: 'player_container',
                child: Material(
                  type: MaterialType.transparency,
                  child: PlayerClipperContainer(
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
                              StreamBuilder<int>(
                                stream: context
                                    .watch<PlayerCubit>()
                                    .getCurrentSongPosition(),
                                builder: (context, snapshot) => SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: CircularProgressIndicator(
                                    value:
                                        (snapshot.data ?? 0) /
                                        (currentSong?.duration ?? 1),
                                    strokeWidth: 3,
                                    backgroundColor: primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    valueColor: AlwaysStoppedAnimation(
                                      primaryColor,
                                    ),
                                  ),
                                ),
                              ),

                              QueryArtworkWidget(
                                id: currentSong?.id ?? -1,
                                type: ArtworkType.AUDIO,
                                artworkWidth: (isPlaying ? 24 : 20) * 2,
                                artworkHeight: (isPlaying ? 24 : 20) * 2,
                                errorBuilder: (_, _, _) => CircleAvatar(
                                  radius: isPlaying ? 24 : 20,
                                  backgroundColor: context.musicLightGrey,
                                  backgroundImage: AssetImage(
                                    context.imagePlaceholder,
                                  ),
                                ),
                                nullArtworkWidget: CircleAvatar(
                                  radius: isPlaying ? 24 : 20,
                                  backgroundColor: context.musicLightGrey,
                                  backgroundImage: AssetImage(
                                    context.imagePlaceholder,
                                  ),
                                ),
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
                              primaryColor: isPlaying
                                  ? primaryColor
                                  : context.musicWhite,
                              onPressed: () =>
                                  context.read<PlayerCubit>().togglePlayPause(),
                              child: Icon(
                                isPlaying
                                    ? FontAwesomeIcons.solidPause
                                    : FontAwesomeIcons.solidPlay,
                                color: isPlaying
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
