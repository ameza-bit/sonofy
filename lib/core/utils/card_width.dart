import 'package:flutter/material.dart' show BoxConstraints;

double cardWidth({
  required BoxConstraints constraints,
  required double maxWidth,
  required double padding,
}) =>
    maxWidth +
    ((constraints.maxWidth % maxWidth) / (constraints.maxWidth ~/ maxWidth)) -
    padding;
