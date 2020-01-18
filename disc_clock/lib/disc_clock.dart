// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

class DiscClock extends StatefulWidget {
  const DiscClock(this.model);

  final ClockModel model;

  @override
  _DiscClockState createState() => _DiscClockState();
}

class _DiscClockState extends State<DiscClock>
    with SingleTickerProviderStateMixin {
  var _now = DateTime.now();
  var _temperature = '';
  var _temperatureRange = '';
  var _condition = '';
  var _location = '';

  Timer _timer;
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInExpo,
    );

    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DiscClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
      _temperatureRange = '(${widget.model.low} - ${widget.model.highString})';
      _condition = widget.model.weatherString;
      _location = widget.model.location;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );

      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).copyWith(
            // Hour hand.
            primaryColor: Color(0xFF4285F4),
            // Minute hand.
            highlightColor: Color(0xFF8AB4F8),
            // Second hand.
            accentColor: Color(0xFF669DF6),
            backgroundColor: Color(0xFFD2E3FC),
          )
        : Theme.of(context).copyWith(
            primaryColor: Color(0xFFD2E3FC),
            highlightColor: Color(0xFF4285F4),
            accentColor: Color(0xFF8AB4F8),
            backgroundColor: Color(0xFF3C4043),
          );

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(color: customTheme.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_temperature),
          Text(_temperatureRange),
          Text(_condition),
          Text(_location),
        ],
      ),
    );

    final newMinute = _now.second == 0;
    final newMinuteTen = newMinute && _now.minute % 10 == 0;
    final newHour = newMinute && _now.minute == 0;
    final newHourTen = newHour && _now.hour % 10 == 0;
    final newDay = newHour && _now.hour == 0;

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Container(
        color: customTheme.backgroundColor,
        child: Stack(
          children: [
            Positioned(
              width: 1000,
              height: 1000,
              top: -350,
              left: -550,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget _widget) {
                  return Transform.rotate(
                    angle: radians(6) * _animation.value,
                    child: _widget,
                  );
                },
                child: Transform.rotate(
                  angle: (_now.second - 1) * radians(6),
                  child: Image.asset('assets/6.webp'),
                ),
              ),
            ),
            Positioned(
              width: 900,
              height: 900,
              top: -300,
              left: -500,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget _widget) {
                  double degrees = _now.second % 10 == 0 ? 6 : 0;

                  return Transform.rotate(
                    angle: radians(degrees) * _animation.value,
                    child: _widget,
                  );
                },
                child: Transform.rotate(
                  angle: ((_now.second - 1) / 10).floor() * radians(6),
                  child: Image.asset('assets/5.webp'),
                ),
              ),
            ),
            Positioned(
              width: 800,
              height: 800,
              top: -250,
              left: -450,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget _widget) {
                  double degrees = newMinute ? 6 : 0;

                  return Transform.rotate(
                    angle: radians(degrees) * _animation.value,
                    child: _widget,
                  );
                },
                child: Transform.rotate(
                  angle: (_now.minute - (newMinute ? 1 : 0)) * radians(6),
                  child: Image.asset('assets/4.webp'),
                ),
              ),
            ),
            Positioned(
              width: 700,
              height: 700,
              top: -200,
              left: -400,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget _widget) {
                  double degrees = newMinuteTen ? 7.5 : 0;

                  return Transform.rotate(
                      angle: radians(degrees) * _animation.value,
                      child: _widget);
                },
                child: Transform.rotate(
                  angle: ((_now.minute - (newMinuteTen ? 1 : 0)) / 10).floor() *
                      radians(7.5),
                  child: Image.asset('assets/3.webp'),
                ),
              ),
            ),
            Positioned(
              width: 600,
              height: 600,
              top: -150,
              left: -350,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget _widget) {
                  double degrees = newHour ? 9 : 0;

                  // Handle the change from 23 to 00
                  // Go forward 7 numbers rather than one (9° * 7)
                  if (_now.hour == 0 && degrees > 0) {
                    degrees = 63;
                  }

                  return Transform.rotate(
                    angle: radians(degrees) * _animation.value,
                    child: _widget,
                  );
                },
                child: Transform.rotate(
                  // Handle the change from 23 to 00
                  angle: (newDay ? 3 : (_now.hour - (newHour ? 1 : 0))) *
                      radians(9),
                  child: Image.asset('assets/2.webp'),
                ),
              ),
            ),
            Positioned(
              width: 500,
              height: 500,
              top: -100,
              left: -300,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget _widget) {
                  double degrees = newHourTen ? 12 : 0;

                  return Transform.rotate(
                    angle: radians(degrees) * _animation.value,
                    child: _widget,
                  );
                },
                child: Transform.rotate(
                  angle: ((_now.hour - (newHourTen ? 1 : 0)) / 10).floor() *
                      radians(12),
                  child: Image.asset('assets/1.webp'),
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: weatherInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
