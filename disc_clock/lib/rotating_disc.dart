import 'package:flutter/material.dart';

import 'disc.dart';

abstract class RotatingDisc extends Disc {
  const RotatingDisc({
    @required String image,
    @required int position,
    @required this.animation,
  })  : assert(image != null),
        assert(position != null),
        assert(animation != null),
        super(
          image: image,
          position: position,
        );

  final Animation animation;

  double initialRotation();
  double targetRotation();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: edgeLength(),
      height: edgeLength(),
      top: positionTop(),
      left: positionLeft(),
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget _widget) {
          return Transform.rotate(
            angle: targetRotation(),
            child: _widget,
          );
        },
        child: Transform.rotate(
          angle: initialRotation(),
          child: Image.asset('assets/$image'),
        ),
      ),
    );
  }
}
