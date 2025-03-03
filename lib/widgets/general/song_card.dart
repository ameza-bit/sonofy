import 'package:flutter/material.dart';
import 'package:sonofy/widgets/player/song_info.dart';

class SongCard extends StatelessWidget {
  const SongCard({super.key});

  @override
  Widget build(BuildContext context) {
    Widget playButton = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.purple, width: 2),
      ),
      child: Icon(
        Icons.play_arrow,
        color: Colors.purple,
        size: 32,
      ),
    );

    if (true) {
      playButton = Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purple],
          ),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.pause,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {},
        ),
      );
    }

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
          playButton,
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
