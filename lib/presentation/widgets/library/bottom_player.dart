import 'package:flutter/material.dart';
import 'package:sonofy/presentation/widgets/library/bottom_clipper_container.dart';

class BottomPlayer extends StatelessWidget {
  const BottomPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return  BottomClipperContainer(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: Container(
              color: Colors.amber,
              child: Row(
                spacing: 16,
                children: [
                ],
              ),
            ),
          ),
        );
  }
}