import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';

import 'number_disc.dart';
import 'static_disc.dart';
import 'weather_disc.dart';

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
  var _condition;

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
      _condition = widget.model.weatherCondition;
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
    final lightMode = Theme.of(context).brightness == Brightness.light;
    final mode = lightMode ? 'light' : 'dark';

    final time = DateFormat.Hms().format(DateTime.now());
    final weatherInfo = DefaultTextStyle(
      style: TextStyle(
        color: Color(0xFFD63D00),
        fontFamily: 'VT323',
        fontSize: 24,
      ),
      child: Text(_temperature),
    );

    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Digital clock with time $time',
        value: time,
      ),
      child: Container(
        color: lightMode ? Color(0xFFFFFFFF) : Color(0xFF000000),
        child: Stack(
          children: [
            NumberDisc(
              image: '$mode/6.webp',
              position: 8,
              animation: _animation,
              now: _now,
            ),
            NumberDisc(
              image: '$mode/5.webp',
              position: 7,
              animation: _animation,
              now: _now,
            ),
            NumberDisc(
              image: '$mode/4.webp',
              position: 6,
              animation: _animation,
              now: _now,
            ),
            NumberDisc(
              image: '$mode/3.webp',
              position: 5,
              animation: _animation,
              now: _now,
            ),
            NumberDisc(
              image: '$mode/2.webp',
              position: 4,
              animation: _animation,
              now: _now,
              is24HourFormat: widget.model.is24HourFormat,
            ),
            NumberDisc(
              image: '$mode/1.webp',
              position: 3,
              animation: _animation,
              now: _now,
              is24HourFormat: widget.model.is24HourFormat,
            ),
            StaticDisc(
              image: '$mode/spacer.webp',
              position: 2,
            ),
            WeatherDisc(
              image: '$mode/weather.webp',
              position: 1,
              animation: _animation,
              condition: _condition,
            ),
            StaticDisc(
              image: 'inner.webp',
              position: 0,
            ),
            Positioned(
              width: 1200,
              height: 1200,
              top: -600 + MediaQuery.of(context).size.height / 2,
              left: -600,
              child: Image.asset('assets/overlay.webp'),
            ),
            Positioned(
              left: 12,
              top: MediaQuery.of(context).size.height / 2 - 12,
              child: weatherInfo,
            ),
          ],
        ),
      ),
    );
  }
}
