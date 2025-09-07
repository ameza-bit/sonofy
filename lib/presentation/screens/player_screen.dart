import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/blocs/player/player_cubit.dart';
import 'package:sonofy/presentation/blocs/player/player_state.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_clipper_container.dart';
import 'package:sonofy/presentation/widgets/options/options_modal.dart';
import 'package:sonofy/presentation/widgets/options/song_info_option.dart';
import 'package:sonofy/presentation/widgets/player/player_control.dart';
import 'package:sonofy/presentation/widgets/player/player_bottom_modals.dart';
import 'package:sonofy/presentation/widgets/player/player_slider.dart';
import 'package:sonofy/presentation/widgets/player/gesture_indicator.dart';

class PlayerScreen extends StatefulWidget {
  static const String routeName = 'player';
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _speedIndicatorVisible = false;
  bool _volumeIndicatorVisible = false;

  void _showSpeedIndicator() {
    setState(() {
      _speedIndicatorVisible = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _speedIndicatorVisible = false;
        });
      }
    });
  }

  void _showVolumeIndicator() {
    setState(() {
      _volumeIndicatorVisible = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _volumeIndicatorVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<PlayerCubit, PlayerState>(
      buildWhen: (previous, current) =>
          previous.currentSong?.id != current.currentSong?.id ||
          previous.isPlaying != current.isPlaying ||
          previous.playbackSpeed != current.playbackSpeed ||
          previous.volume != current.volume,
      builder: (context, state) {
        final currentSong = state.currentSong;

        final songName = currentSong?.title ?? '';
        final artistName = currentSong?.artist ?? currentSong?.composer ?? '';

        final emptyImage = Image.asset(
          context.imagePlaceholder,
          width: double.infinity,
          height: size.height * 0.6,
          fit: BoxFit.fitHeight,
          colorBlendMode: BlendMode.darken,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: context.musicWhite,
            actionsPadding: const EdgeInsets.only(right: 12.0),
            leading: IconButton(
              icon: const Icon(FontAwesomeIcons.lightChevronLeft, size: 20.0),
              onPressed: () => context.pop(),
            ),
            title: Text(
              context.tr('player.now_playing').toUpperCase(),
              style: TextStyle(
                fontSize: context.scaleText(16),
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  FontAwesomeIcons.lightEllipsisStrokeVertical,
                  size: 20.0,
                ),
                onPressed: OptionsModal(context).player,
              ),
            ],
          ),
          body: Stack(
            children: [
              QueryArtworkWidget(
                id: currentSong?.id ?? -1,
                type: ArtworkType.AUDIO,
                artworkBorder: BorderRadius.zero,
                artworkWidth: size.width.clamp(200, 800),
                artworkHeight: (size.height * 0.6).clamp(300, 600),
                artworkFit: BoxFit.fitHeight,
                errorBuilder: (_, _, _) => emptyImage,
                nullArtworkWidget: Builder(
                  builder: (_) {
                    final currentSongInfo = state.currentSong?.getMap ?? {};
                    if (currentSongInfo.containsKey('artwork') &&
                        currentSongInfo['artwork'] is Picture) {
                      final Picture artworkData = currentSongInfo['artwork'];
                      return Image.memory(
                        artworkData.bytes,
                        width: double.infinity,
                        height: size.height * 0.6,
                        fit: BoxFit.fitHeight,
                        colorBlendMode: BlendMode.darken,
                        errorBuilder: (_, _, _) => emptyImage,
                      );
                    }

                    return emptyImage;
                  },
                ),
              ),
              // Indicadores visuales
              Positioned(
                left: size.width * 0.1,
                top: size.height * 0.25,
                child: GestureIndicator(
                  label: context.tr('player.gestures.speed_label'),
                  value: '${state.playbackSpeed}x',
                  icon: Icons.speed,
                  isVisible: _speedIndicatorVisible,
                ),
              ),
              Positioned(
                right: size.width * 0.1,
                top: size.height * 0.25,
                child: GestureIndicator(
                  label: context.tr('player.gestures.volume_label'),
                  value: '${(state.volume * 100).round()}%',
                  icon: Icons.volume_up,
                  isVisible: _volumeIndicatorVisible,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onPanUpdate: (details) {
                      // Control de velocidad - lado izquierdo
                      final playerCubit = context.read<PlayerCubit>();
                      final deltaY = details.delta.dy;

                      // Sensibilidad del gesto (ajustar según necesidad)
                      if (deltaY < -5) {
                        // Deslizar hacia arriba = aumentar velocidad
                        playerCubit.increaseSpeed();
                        _showSpeedIndicator();
                      } else if (deltaY > 5) {
                        // Deslizar hacia abajo = disminuir velocidad
                        playerCubit.decreaseSpeed();
                        _showSpeedIndicator();
                      }
                    },
                    child: ColoredBox(
                      color: context.musicDeepBlack.withValues(alpha: 0.5),
                      child: SizedBox(
                        width: size.width * 0.15,
                        height: size.height * 0.6,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<PlayerCubit>().togglePlayPause(),
                    onDoubleTap: () =>
                        context.read<PlayerCubit>().toggleRepeat(),
                    onVerticalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! > 0) {
                          // Deslizar hacia abajo = cerrar pantalla
                          context.pop();
                        } else if (details.primaryVelocity! < 0 &&
                            state.currentSong != null) {
                          // Deslizar hacia arriba = mostrar info de la canción
                          SongInfoOption.show(context, state.currentSong!);
                        }
                      }
                    },
                    onHorizontalDragEnd: (details) {
                      final playerCubit = context.read<PlayerCubit>();
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! > 0) {
                          // Deslizar hacia la derecha = canción anterior
                          playerCubit.previousSong();
                        } else if (details.primaryVelocity! < 0) {
                          // Deslizar hacia la izquierda = siguiente canción
                          playerCubit.nextSong();
                        }
                      }
                    },
                    child: ColoredBox(
                      color: context.musicDeepBlack.withValues(alpha: 0.5),
                      child: SizedBox(
                        width: size.width * 0.7,
                        height: size.height * 0.6,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onPanUpdate: (details) {
                      // Control de volumen - lado derecho
                      final playerCubit = context.read<PlayerCubit>();
                      final deltaY = details.delta.dy;

                      // Sensibilidad del gesto para volumen (más sensible)
                      if (deltaY < -3) {
                        // Deslizar hacia arriba = aumentar volumen
                        playerCubit.increaseVolume(0.05);
                        _showVolumeIndicator();
                      } else if (deltaY > 3) {
                        // Deslizar hacia abajo = disminuir volumen
                        playerCubit.decreaseVolume(0.05);
                        _showVolumeIndicator();
                      }
                    },
                    child: ColoredBox(
                      color: context.musicDeepBlack.withValues(alpha: 0.5),
                      child: SizedBox(
                        width: size.width * 0.15,
                        height: size.height * 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Spacer(),
                  Hero(
                    tag: 'player_container',
                    child: Material(
                      type: MaterialType.transparency,
                      child: BottomClipperContainer(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PlayerSlider(
                              durationMiliseconds: currentSong?.duration ?? 0,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              songName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.scaleText(20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              artistName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.scaleText(12),
                                color: context.musicLightGrey,
                              ),
                            ),
                            const SizedBox(height: 30),
                            const PlayerControl(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          ),
          bottomNavigationBar: const PlayerBottomModals(),
        );
      },
    );
  }
}
