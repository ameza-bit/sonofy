import 'package:flutter/material.dart';
import 'package:sonofy/widgets/general/clipper_container.dart';

class CurvedImageView extends StatelessWidget {
  const CurvedImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: ClipPath(
          clipper: MusicContainerClipper(),
          child: Container(
            width: 300,
            height: 300,
            color: Colors.pink,
          ),
        ),
      ),
    );
  }
}
