import 'package:flutter/material.dart';

class CurvedImageView extends StatelessWidget {
  const CurvedImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: ClipPath(
          clipper: MyCustomClipper(),
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

class MyCustomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width;
    double h = size.height;
    double roundness = 80;

    Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, h - roundness);
    path.quadraticBezierTo(0, h, roundness, h);
    path.lineTo(w - roundness, h);
    path.quadraticBezierTo(w, h, w, h - roundness);
    path.lineTo(w, roundness * 2);
    path.quadraticBezierTo(w, roundness, w - roundness, roundness);
    path.lineTo(roundness, roundness);
    path.quadraticBezierTo(0, roundness, 0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
