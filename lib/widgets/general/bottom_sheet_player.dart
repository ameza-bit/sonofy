import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sonofy/providers/player_provider.dart';
import 'package:sonofy/screens/music_player_screen.dart';
import 'package:sonofy/widgets/general/clipper_container.dart';
import 'package:sonofy/widgets/player/play_button.dart';
import 'package:sonofy/widgets/player/song_info.dart';

class BottomSheetPlayer extends StatelessWidget {
  const BottomSheetPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerWatcher = context.watch<PlayerProvider>();

    return InkWell(
      onTap: () => context.goNamed(MusicPlayerScreen.routeName),
      child: ClipperContainer(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: SafeArea(
          child: Row(
            spacing: 16,
            children: [
              Hero(
                tag: "song-image-cover",
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                    image: DecorationImage(
                      image: NetworkImage(playerWatcher.currentSong?.songCover ?? 'https://centenaries.ucd.ie/wp-content/uploads/2017/05/placeholder-400x600.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(child: SongInfo(isBottomSheet: true)),
              PlayButton(size: 60),
            ],
          ),
        ),
      ),
    );
  }
}
