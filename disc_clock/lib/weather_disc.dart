import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'rotating_disc.dart';

class WeatherDisc extends RotatingDisc {
  const WeatherDisc({
    @required String image,
    @required int position,
    @required Animation animation,
    @required this.condition,
  })  : assert(image != null),
        assert(position != null),
        assert(animation != null),
        assert(condition != null),
        super(
          image: image,
          position: position,
          animation: animation,
        );

  final WeatherCondition condition;

  double initialRotation() {
    return condition.index * radians(25.714);
  }

  double targetRotation() {
    // todo
    return 0;
  }
}
