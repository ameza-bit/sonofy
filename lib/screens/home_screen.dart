import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonofy/models/song.dart';
import 'package:sonofy/providers/player_provider.dart';
import 'package:sonofy/widgets/general/bottom_sheet_player.dart';
import 'package:sonofy/widgets/general/song_card.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = 'home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerWatcher = context.watch<PlayerProvider>();

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: ListView(
            children: [
              for (Song song in playerWatcher.playlist) SongCard(song),
              const SizedBox(height: 75),
            ],
          ),
        ),
      ),
      bottomSheet: BottomSheetPlayer(),
    );
  }
}
