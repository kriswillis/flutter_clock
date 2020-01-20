import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'rotating_disc.dart';

class NumberDisc extends RotatingDisc {
  const NumberDisc({
    @required String image,
    @required int position,
    @required Animation animation,
    @required this.now,
    this.is24HourFormat = false,
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
  final bool is24HourFormat;

  double initialRotation() {
    switch (position) {
      case 8: // Seconds (Right)
        return (now.second - 1) * radians(6);
      case 7: // Seconds (Left)
        return ((now.second - 1) / 10).floor() * radians(6);
      case 6: // Minutes (Right)
        return (now.minute - (_isNewMinute() ? 1 : 0)) * radians(6);
      case 5: // Minutes (Left)
        return ((now.minute - (_isNewMinuteTen() ? 1 : 0)) / 10).floor() *
            radians(7.5);
      case 4: // Hours (Right)
        if (is24HourFormat) {
          if (_isNewDay()) {
            // Change from 2(3) to 0(0)
            return 3 * radians(9);
          }

          return (now.hour - (_isNewHour() ? 1 : 0)) * radians(9);
        }

        if (_get12Hour() == 1 && _isNewHour()) {
          // Change from 1(2) to 0(1)
          return 2 * radians(9);
        }

        return (_get12Hour() - (_isNewHour() ? 1 : 0)) * radians(9);
      case 3: // Hours (Left)
        if (is24HourFormat) {
          return ((now.hour - (_isNewHourTen() ? 1 : 0)) / 10).floor() *
              radians(12);
        }

        if (_get12Hour() == 1 && _isNewHour()) {
          // Change from (1)2 to (0)1
          return radians(12);
        }

        return ((_get12Hour() - (_isNewHour() ? 1 : 0)) / 10).floor() *
            radians(12);
      default:
        return 0;
    }
  }

  double targetRotation() {
    double degrees = 0;

    switch (position) {
      case 8: // Seconds (Right)
        degrees = 6;
        break;
      case 7: // Seconds (Left)
        degrees = now.second % 10 == 0 ? 6 : 0;
        break;
      case 6: // Minutes (Right)
        degrees = _isNewMinute() ? 6 : 0;
        break;
      case 5: // Minutes (Left)
        degrees = _isNewMinuteTen() ? 7.5 : 0;
        break;
      case 4: // Hours (Right)
        degrees = _isNewHour() ? 9 : 0;

        if (is24HourFormat) {
          if (now.hour == 0 && degrees > 0) {
            // Change from 2(3) to 0(0): +7 × 9°
            degrees = 63;
          }
        } else if (_get12Hour() == 1 && degrees > 0) {
          // Change from 1(2) to 0(1): +9 × 9°
          degrees = 81;
        }
        break;
      case 3: // Hours (Left)
        if (is24HourFormat) {
          degrees = _isNewHourTen() ? 12 : 0;
        } else if (_isNewHour() && _get12Hour() == 1) {
          degrees = 24; // Change from (1)2 to (0)1: +2 × 12°
        } else if (_isNewHour() && _get12Hour() == 10) {
          degrees = 12; // Change from (0)9 to (1)0: +1 × 12°
        }
        break;
    }

    return radians(degrees) * animation.value;
  }

  bool _isNewMinute() => now.second == 0;

  bool _isNewMinuteTen() => _isNewMinute() && now.minute % 10 == 0;

  bool _isNewHour() => _isNewMinute() && now.minute == 0;

  bool _isNewHourTen() => _isNewHour() && now.hour % 10 == 0;

  bool _isNewDay() => _isNewHour() && now.hour == 0;

  double _get12Hour() => double.parse(DateFormat('hh').format(now));
}
