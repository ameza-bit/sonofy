import 'package:flutter/material.dart';

class SongInfo extends StatelessWidget {
  const SongInfo({this.isBottomSheet = false, super.key});

  final bool isBottomSheet;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Different World (feat. COR...',
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
          'Alan Walker, K-391 & Sofia Carson',
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
