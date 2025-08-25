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
import 'package:sonofy/presentation/widgets/player/player_control.dart';
import 'package:sonofy/presentation/widgets/player/player_bottom_modals.dart';
import 'package:sonofy/presentation/widgets/player/player_slider.dart';

class PlayerScreen extends StatelessWidget {
  static const String routeName = 'player';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final currentSong = state.currentSong;

        final songName = currentSong?.title ?? '';
        final artistName = currentSong?.artist ?? currentSong?.composer ?? '';

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
                artworkWidth: double.infinity,
                artworkHeight: size.height * 0.6,
                artworkFit: BoxFit.fitHeight,
                errorBuilder: (_, _, _) => Image.asset(
                  context.imagePlaceholder,
                  width: double.infinity,
                  height: size.height * 0.6,
                  fit: BoxFit.fitHeight,
                  colorBlendMode: BlendMode.darken,
                ),
                nullArtworkWidget: Image.asset(
                  context.imagePlaceholder,
                  width: double.infinity,
                  height: size.height * 0.6,
                  fit: BoxFit.fitHeight,
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 0) {
                    context.pop();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.6,
                  color: context.musicDeepBlack.withValues(alpha: 0.5),
                ),
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
