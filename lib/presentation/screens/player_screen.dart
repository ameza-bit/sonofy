import 'package:flutter/material.dart';
import 'package:sonofy/presentation/widgets/library/bottom_clipper_container.dart';
import 'package:sonofy/presentation/widgets/player/player_app_bar.dart';
import 'package:sonofy/presentation/widgets/player/player_body.dart';
import 'package:sonofy/presentation/widgets/player/player_lyrics.dart';

class PlayerScreen extends StatelessWidget {
  static const String routeName = 'player';
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const PlayerAppBar(),
      body: Stack(
        children: [
          Image.network(
            width: double.infinity,
            height: mediaQuery.size.height * 0.6,
            'https://static.wikia.nocookie.net/hellokitty/images/2/20/Sanrio_Characters_My_Sweet_Piano_Image002.jpg/revision/latest?cb=20170327084137',
            fit: BoxFit.fitHeight,
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            children: [
              SizedBox(height: mediaQuery.size.height * 0.45),
              const BottomClipperContainer(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: PlayerBody(),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: const PlayerLyrics(),
    );
  }
}
