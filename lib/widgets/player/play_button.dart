import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonofy/providers/player_provider.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({this.size = 80, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerWatcher = context.watch<PlayerProvider>();
    PlayerProvider playerReader = context.read<PlayerProvider>();

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
        ),
      ),
      child: IconButton(
        icon: Icon(
          playerWatcher.isPlaying ? Icons.pause : Icons.play_arrow,
          size: 40,
          color: Colors.white,
        ),
        onPressed: () => playerReader.toggleState(),
      ),
    );
  }
}
