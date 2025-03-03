import 'package:flutter/material.dart';

class ClipperContainer extends StatelessWidget {
  const ClipperContainer({
    this.padding,
    required this.child,
    super.key,
  });

  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MusicContainerClipper(),
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 80),
            child,
          ],
        ),
      ),
    );
  }
}

class MusicContainerClipper extends CustomClipper<Path> {
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
