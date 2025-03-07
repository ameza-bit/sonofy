import 'package:flutter/material.dart';
import 'package:sonofy/widgets/general/bottom_sheet_player.dart';
import 'package:sonofy/widgets/general/song_card.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = 'home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: ListView(
            children: [
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              SongCard(),
              const SizedBox(height: 75),
            ],
          ),
        ),
      ),
      bottomSheet: BottomSheetPlayer(),
    );
  }
}
