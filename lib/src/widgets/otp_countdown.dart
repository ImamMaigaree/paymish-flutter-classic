import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/dimens.dart';

class Countdown extends AnimatedWidget {
  const Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  Widget build(BuildContext context) {
    final clockTimer = Duration(seconds: animation.value);
    final timerText =
        '''${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}''';
    return Text(
      timerText,
      style: TextStyle(
        fontSize: fontLarger,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<int>>('animation', animation));
  }
}
