import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'rotating_disc.dart';

class NumberDisc extends RotatingDisc {
  const NumberDisc({
    @required String image,
    @required int position,
    @required Animation animation,
    @required this.now,
  })  : assert(image != null),
        assert(position != null),
        assert(animation != null),
        assert(now != null),
        super(
          image: image,
          position: position,
          animation: animation,
        );

  final DateTime now;

  double initialRotation() {
    final newMinute = now.second == 0;
    final newMinuteTen = newMinute && now.minute % 10 == 0;
    final newHour = newMinute && now.minute == 0;
    final newHourTen = newHour && now.hour % 10 == 0;
    final newDay = newHour && now.hour == 0;

    switch (position) {
      case 8:
        return (now.second - 1) * radians(6);
      case 7:
        return ((now.second - 1) / 10).floor() * radians(6);
      case 6:
        return (now.minute - (newMinute ? 1 : 0)) * radians(6);
      case 5:
        return ((now.minute - (newMinuteTen ? 1 : 0)) / 10).floor() *
            radians(7.5);
      case 4:
        // Handle the change from 23 to 00
        return (newDay ? 3 : (now.hour - (newHour ? 1 : 0))) * radians(9);
      case 3:
        return ((now.hour - (newHourTen ? 1 : 0)) / 10).floor() * radians(12);
      default:
        return 0;
    }
  }

  double targetRotation() {
    final newMinute = now.second == 0;
    final newMinuteTen = newMinute && now.minute % 10 == 0;
    final newHour = newMinute && now.minute == 0;
    final newHourTen = newHour && now.hour % 10 == 0;

    double degrees = 0;

    switch (position) {
      case 8:
        degrees = 6;
        break;
      case 7:
        degrees = now.second % 10 == 0 ? 6 : 0;
        break;
      case 6:
        degrees = newMinute ? 6 : 0;
        break;
      case 5:
        degrees = newMinuteTen ? 7.5 : 0;
        break;
      case 4:
        degrees = newHour ? 9 : 0;
        // Handle the change from 23 to 00
        // Go forward 7 numbers rather than one (9° * 7)
        if (now.hour == 0 && degrees > 0) {
          degrees = 63;
        }
        break;
      case 3:
        degrees = newHourTen ? 12 : 0;
        break;
      default:
        return 0;
    }

    return radians(degrees) * animation.value;
  }
}
