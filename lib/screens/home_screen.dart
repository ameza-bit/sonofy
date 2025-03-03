import 'package:flutter/material.dart';
import 'package:sonofy/widgets/general/bottom_sheet_player.dart';
import 'package:sonofy/widgets/general/song_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SongCard(),
            SongCard(),
            SongCard(),
            SongCard(),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      bottomSheet: BottomSheetPlayer(),
    );
  }
}
