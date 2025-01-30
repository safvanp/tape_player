import 'package:flutter/material.dart';

class TunerPainter extends CustomPainter {
  final double rotationValue;
  final double progress;

  TunerPainter({required this.rotationValue, required this.progress});

  late double holeRadius;
  late Offset leftHolePosition;
  late Offset rightHolePosition;
  late Path leftHole;
  late Path rightHole;
  late Path centerWindowPath;
  late Paint paintObject;
  late Size size;
  late Canvas canvas;

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    holeRadius = size.height / 12;
    paintObject = Paint();

    // _initHoles();
    _initLineTuner();
  }

  void _initHoles() {
    leftHolePosition = Offset(size.width * 0.3, size.height * 0.46);
    rightHolePosition = Offset(size.width * 0.7, size.height * 0.46);

    leftHole = Path()
      ..addOval(Rect.fromCircle(center: leftHolePosition, radius: holeRadius));

    rightHole = Path()
      ..addOval(Rect.fromCircle(center: rightHolePosition, radius: holeRadius));
  }

  void _initCenterWindow() {
    Rect centerWindow = Rect.fromLTRB(size.width * 0.4, size.height * 0.37,
        size.width * 0.6, size.height * 0.55);
    centerWindowPath = Path()..addRect(centerWindow);
  }

  // void _drawTape() {
  //   RRect tape = RRect.fromRectAndRadius(
  //       Rect.fromLTRB(0, 0, size.width, size.height), Radius.circular(16));

  //   Path tapePath = Path()..addRRect(tape);

  //   tapePath = _cutHolesIntoPath(tapePath);
  //   tapePath = _cutCenterWindowIntoPath(tapePath);

  //   canvas.drawShadow(tapePath, Colors.black, 3.0, false);
  //   paintObject.color = Colors.black;
  //   paintObject.color = Color(0xff522f19).withValues(alpha: 0.8);
  //   canvas.drawPath(tapePath, paintObject);
  // }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _initLineTuner() {
    paintObject.color = Colors.teal;
    paintObject.strokeWidth = 8;
    paintObject.strokeCap = StrokeCap.round;
    Offset startingOffset = Offset(0, size.height);
    Offset endingOffset = Offset(size.width, size.height);
    canvas.drawLine(startingOffset, endingOffset, paintObject);
  }
}
