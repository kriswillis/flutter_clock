import 'package:flutter/material.dart';

abstract class Disc extends StatelessWidget {
  const Disc({
    @required this.image,
    @required this.position,
  })  : assert(image != null),
        assert(position != null);

  final String image;
  final int position;
  final int maxDiscs = 8;

  // todo: Figure out how to make this stuff responsive

  double edgeLength() {
    final double max = 1000;
    final double step = 100;

    return max - ((maxDiscs - position) * step);
  }

  double positionTop() {
    final double max = -342;
    final double step = 50;

    return max + ((maxDiscs - position) * step);
  }

  double positionLeft() {
    final double max = -500;
    final double step = 50;

    return max + ((maxDiscs - position) * step);
  }
}
