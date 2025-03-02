import 'package:flutter/material.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
