import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonofy/providers/player_provider.dart';

class SongInfo extends StatelessWidget {
  const SongInfo({this.isBottomSheet = false, super.key});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context) {
    PlayerProvider playerWatcher = context.watch<PlayerProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          playerWatcher.currentSong?.title ?? '',
          style: TextStyle(
            color: Colors.black,
            fontSize: isBottomSheet ? 18 : 24,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        if (!isBottomSheet) const SizedBox(height: 4),
        Text(
          playerWatcher.currentSong?.artist ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: isBottomSheet ? 14 : 16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }
}
