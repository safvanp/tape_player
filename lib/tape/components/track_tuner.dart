import 'package:flutter/material.dart';
import 'package:tape_player/tape/components/tuner_painter.dart';

class TrackTuner extends StatelessWidget {
  final double currentPosition;
  final double controllerValue;
  const TrackTuner(
      {super.key,
      required this.controllerValue,
      required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: CustomPaint(
        painter: TunerPainter(
            rotationValue: controllerValue, progress: currentPosition),
      ),
    );
  }
}
