import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';
import 'package:sonofy/core/extensions/theme_extensions.dart';
import 'package:sonofy/presentation/widgets/common/font_awesome/font_awesome_flutter.dart';
import 'package:sonofy/presentation/widgets/library/bottom_clipper_container.dart';
import 'package:sonofy/presentation/widgets/player/player_control.dart';
import 'package:sonofy/presentation/widgets/player/player_lyrics.dart';
import 'package:sonofy/presentation/widgets/player/player_slider.dart';

class PlayerScreen extends StatelessWidget {
  static const String routeName = 'player';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
            icon: const Icon(FontAwesomeIcons.lightHeart, size: 20.0),
            onPressed: () {
              // Show more options
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            width: double.infinity,
            height: size.height * 0.6,
            'assets/images/piano.png',
            fit: BoxFit.fitHeight,
            colorBlendMode: BlendMode.darken,
          ),
          Container(
            width: double.infinity,
            height: size.height * 0.6,
            color: context.musicDeepBlack.withValues(alpha: 0.5),
          ),
          Column(
            children: [
              SizedBox(height: size.height * 0.45),
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
                        const PlayerSlider(),
                        const SizedBox(height: 16),
                        Text(
                          'Different world of music',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
            ],
          ),
        ],
      ),
      bottomNavigationBar: const PlayerLyrics(),
    );
  }
}
