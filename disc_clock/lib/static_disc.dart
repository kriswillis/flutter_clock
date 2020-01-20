import 'package:flutter/material.dart';

import 'disc.dart';

class StaticDisc extends Disc {
  const StaticDisc({
    @required String image,
    @required int position,
  })  : assert(image != null),
        assert(position != null),
        super(
          image: image,
          position: position,
        );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: edgeLength(),
      height: edgeLength(),
      top: positionTop(context),
      left: positionLeft(),
      child: Image.asset('assets/$image'),
    );
  }
}
