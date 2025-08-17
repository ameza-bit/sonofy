import 'package:flutter/material.dart';
import 'package:sonofy/core/extensions/color_extensions.dart';

class PlayerClipperContainer extends StatelessWidget {
  const PlayerClipperContainer({required this.child, this.padding, super.key});

  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 4,
          top: -4,
          child: ClipPath(
            clipper: _PlayerContainerClipper(),
            child: ColoredBox(color: context.musicDeepBlack.withAlpha(12)),
          ),
        ),
        ClipPath(
          clipper: _PlayerContainerClipper(),
          child: Container(
            width: double.infinity,
            color: Theme.of(context).cardColor,
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [const SizedBox(height: 80), child],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlayerContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    const double roundness = 80;

    final Path path = Path();

    path.lineTo(0, 0);
    path.lineTo(0, h);
    path.lineTo(w, h);
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
