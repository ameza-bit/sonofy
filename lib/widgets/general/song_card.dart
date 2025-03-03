import 'package:flutter/material.dart';
import 'package:sonofy/widgets/player/play_button.dart';
import 'package:sonofy/widgets/player/song_info.dart';

class SongCard extends StatelessWidget {
  const SongCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        spacing: 12,
        children: [
          PlayButton(size: 60),
          Expanded(child: SongInfo(isBottomSheet: true)),
          Text(
            '2:46',
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
