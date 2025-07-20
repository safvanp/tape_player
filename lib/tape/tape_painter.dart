// tape_painter.dart
import 'dart:math';
import 'package:flutter/material.dart';

class TapePainter extends CustomPainter {
  late double holeRadius;
  late Offset leftHolePosition;
  late Offset rightHolePosition;
  late Path leftHole;
  late Path rightHole;
  late Path centerWindowPath;

  late Paint paintObject;
  late Size size;
  late Canvas canvas;

  double rotationValue;
  String title;
  double progress;

  TapePainter({
    required this.rotationValue,
    required this.title,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    this.canvas = canvas;

    holeRadius = size.height / 12;
    paintObject = Paint();

    _initHoles();
    _initCenterWindow();
    _drawTapeBody();
    _drawTapeReels();
    _drawTapeLabel();
    _drawCenterWindow();
    _drawBlackRect();
    _drawHoleRing();
    _drawTextLabel();
    _drawTapeReelHubs();
    _drawTapePins();
    _drawTopGloss();
    // _drawFixedTextLabels();
    // _drawSideLabel();
    _drawReelMarkers();
    _drawScrews();
  }

  @override
  bool shouldRepaint(covariant TapePainter oldDelegate) {
    return oldDelegate.rotationValue != rotationValue ||
        oldDelegate.progress != progress ||
        oldDelegate.title != title;
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
    Rect centerWindow = Rect.fromLTRB(
      size.width * 0.4,
      size.height * 0.37,
      size.width * 0.6,
      size.height * 0.55,
    );
    centerWindowPath = Path()..addRect(centerWindow);
  }

  void _drawTapeBody() {
    final gradient = LinearGradient(
      colors: [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final tapeRect = Rect.fromLTRB(0, 0, size.width, size.height);
    paintObject.shader = gradient.createShader(tapeRect);

    RRect tape = RRect.fromRectAndRadius(tapeRect, const Radius.circular(16));
    Path tapePath = Path()..addRRect(tape);

    tapePath = _cutHolesIntoPath(tapePath);
    tapePath = _cutCenterWindowIntoPath(tapePath);

    canvas.drawShadow(tapePath, Colors.black, 3.0, false);
    canvas.drawPath(tapePath, paintObject);
    paintObject.shader = null;
  }

  Path _cutCenterWindowIntoPath(Path path) =>
      Path.combine(PathOperation.difference, path, centerWindowPath);

  Path _cutHolesIntoPath(Path path) {
    path = Path.combine(PathOperation.difference, path, leftHole);
    path = Path.combine(PathOperation.difference, path, rightHole);
    return path;
  }

  void _drawTapeLabel() {
    final labelColor = const Color(0xFFEAEAEA).withValues(alpha: 0.2);
    final labelStripeColor = const Color(0xFFEF5350);

    double labelPadding = size.width * 0.05;
    Rect label = Rect.fromLTWH(
      labelPadding,
      labelPadding,
      size.width - labelPadding * 2,
      size.height * 0.7,
    );
    Path labelPath = Path()..addRect(label);
    labelPath = _cutHolesIntoPath(labelPath);
    labelPath = _cutCenterWindowIntoPath(labelPath);

    Rect stripe = Rect.fromLTRB(
      label.left,
      label.top + label.height * 0.2,
      label.right,
      label.top + label.height * 0.3,
    );
    Path stripePath = Path()..addRect(stripe);

    paintObject.color = labelColor;
    canvas.drawPath(labelPath, paintObject);
    paintObject.color = labelStripeColor;
    canvas.drawPath(stripePath, paintObject);
  }

  void _drawCenterWindow() {
    final glassGradient = LinearGradient(
      colors: [Colors.black38, Colors.black12],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    paintObject.shader =
        glassGradient.createShader(centerWindowPath.getBounds());
    canvas.drawPath(centerWindowPath, paintObject);
    paintObject.shader = null;
  }

  void _drawBlackRect() {
    Rect blackRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.31,
        size.width * 0.6, size.height * 0.3);
    Path blackRectPath = Path()..addRRect(RRect.fromRectXY(blackRect, 4, 4));

    blackRectPath =
        Path.combine(PathOperation.difference, blackRectPath, leftHole);
    blackRectPath =
        Path.combine(PathOperation.difference, blackRectPath, rightHole);
    blackRectPath = _cutCenterWindowIntoPath(blackRectPath);

    paintObject.color = const Color.fromRGBO(0, 0, 0, 0.8);
    canvas.drawPath(blackRectPath, paintObject);
  }

  void _drawHoleRing() {
    paintObject.color = Colors.white;
    for (var hole in [leftHolePosition, rightHolePosition]) {
      Path ring = Path()
        ..addOval(Rect.fromCircle(center: hole, radius: holeRadius * 1.1));
      ring = Path.combine(PathOperation.difference, ring,
          Path()..addOval(Rect.fromCircle(center: hole, radius: holeRadius)));
      canvas.drawPath(ring, paintObject);
    }
  }

  void _drawTextLabel() {
    final textStyle = TextStyle(
      color: Colors.red,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(blurRadius: 2, color: Colors.white, offset: Offset(0.5, 0.5))
      ],
    );
    final span = TextSpan(style: textStyle, text: title);
    final textPainter =
        TextPainter(text: span, textDirection: TextDirection.ltr);

    textPainter.layout();
    final RRect tape = RRect.fromRectAndRadius(
      Rect.fromLTRB(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.save();
    canvas.clipRRect(tape);

    final double totalScrollWidth = textPainter.width + 80;
    final double scrollOffset = (rotationValue) * 200;
    double x = -scrollOffset;
    double y = size.height * 0.12;
    while (x < size.width) {
      textPainter.paint(canvas, Offset(x, y));
      x += totalScrollWidth;
    }
    canvas.restore();
  }

  void _drawTapePins() {
    paintObject.color = Colors.white;
    const int pinCount = 8;
    for (var i = 0; i < pinCount; i++) {
      _drawTapePin(leftHolePosition, rotationValue + i / pinCount);
      _drawTapePin(rightHolePosition, rotationValue + i / pinCount);
    }
  }

  void _drawTapePin(Offset center, double angle) {
    _drawRotated(center, -angle, () {
      canvas.drawRect(
        Rect.fromLTWH(center.dx - 2, center.dy - holeRadius, 4, holeRadius / 4),
        paintObject,
      );
    });
  }

  void _drawRotated(Offset center, double angle, Function drawFunction) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle * pi * 2);
    canvas.translate(-center.dx, -center.dy);
    drawFunction();
    canvas.restore();
  }

  void _drawTapeReelHubs() {
    for (final center in [leftHolePosition, rightHolePosition]) {
      final gradient = RadialGradient(
        colors: [
          const Color(0xFF2A2A2A).withValues(alpha: 0.8),
          const Color(0xFF111111)
        ],
        center: Alignment.center,
        radius: 1,
      );

      paintObject.shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: holeRadius * 1.6),
      );

      canvas.drawCircle(center, holeRadius * 1.6, paintObject);
      paintObject.shader = null; // Reset
    }
  }

  void _drawTapeReels() {
    for (var i = 0; i < 2; i++) {
      Offset center = i == 0 ? leftHolePosition : rightHolePosition;
      double radius = holeRadius * ((i == 0 ? 1 - progress : progress) * 5);
      Path reel = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));
      reel = Path.combine(PathOperation.difference, reel,
          Path()..addOval(Rect.fromCircle(center: center, radius: holeRadius)));
      paintObject.color = Colors.black;
      canvas.drawPath(reel, paintObject);
    }
  }

  void _drawTopGloss() {
    paintObject.color = const Color.fromRGBO(255, 255, 255, 0.05);
    final gloss = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(size.width / 2, size.height * 0.15, size.width, 0)
      ..lineTo(size.width, size.height * 0.05)
      ..quadraticBezierTo(
          size.width / 2, size.height * 0.2, 0, size.height * 0.05)
      ..close();
    canvas.drawPath(gloss, paintObject);
  }

  void _drawReelMarkers() {
    paintObject.color = const Color(0xFFDD4A1F); // Orange-red color

    for (var center in [leftHolePosition, rightHolePosition]) {
      _drawRotated(center, -rotationValue, () {
        final double outerRadius = holeRadius * 1.3;
        final double arcStartAngle = -pi / 4;
        final double arcSweepAngle = pi / 4;

        // Draw the arc (thick slice)
        final arcRect = Rect.fromCircle(center: center, radius: outerRadius);
        canvas.drawArc(
            arcRect, arcStartAngle, arcSweepAngle, false, paintObject);

        // Draw the rectangle "tab" at the outer rim of arc
        final double tabWidth = 6;
        final double tabHeight = 12;

        final double tabAngle = arcStartAngle + arcSweepAngle / 2;
        final double tabX = center.dx + outerRadius * cos(tabAngle);
        final double tabY = center.dy + outerRadius * sin(tabAngle);

        canvas.save();
        canvas.translate(tabX, tabY);
        canvas.rotate(tabAngle); // Rotate the tab to match arc angle
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(0, 0), width: tabWidth, height: tabHeight),
          paintObject,
        );
        canvas.restore();
      });
    }
  }

  void _drawScrews() {
    paintObject.color = Colors.grey.shade800;
    const offsetPairs = [
      Offset(10, 10),
      Offset(10, -10),
      Offset(-10, 10),
      Offset(-10, -10),
    ];
    for (final offset in offsetPairs) {
      canvas.drawCircle(
        Offset(
          offset.dx < 0 ? size.width + offset.dx : offset.dx,
          offset.dy < 0 ? size.height + offset.dy : offset.dy,
        ),
        3,
        paintObject,
      );
    }
  }
}

// class TapePainter extends CustomPainter {
//   late double holeRadius;
//   late Offset leftHolePosition;
//   late Offset rightHolePosition;
//   late Path leftHole;
//   late Path rightHole;
//   late Path centerWindowPath;

//   late Paint paintObject;
//   late Size size;
//   late Canvas canvas;

//   double rotationValue;
//   String title;
//   double progress;

//   TapePainter({
//     required this.rotationValue,
//     required this.title,
//     required this.progress,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     this.size = size;
//     this.canvas = canvas;

//     holeRadius = size.height / 12;
//     paintObject = Paint();

//     _initHoles();
//     _initCenterWindow();
//     _drawTape();
//     _drawTapeReels();
//     _drawTapeLabel();
//     _drawCenterWindow();
//     _drawBlackRect();
//     _drawHoleRing();
//     _drawTextLabel();
//     _drawTapePins();
//     _drawTopGloss();
//   }

//   @override
//   bool shouldRepaint(covariant TapePainter oldDelegate) {
//     return oldDelegate.rotationValue != rotationValue ||
//         oldDelegate.progress != progress ||
//         oldDelegate.title != title;
//   }

//   void _initHoles() {
//     leftHolePosition = Offset(size.width * 0.3, size.height * 0.46);
//     rightHolePosition = Offset(size.width * 0.7, size.height * 0.46);

//     leftHole = Path()
//       ..addOval(Rect.fromCircle(center: leftHolePosition, radius: holeRadius));
//     rightHole = Path()
//       ..addOval(Rect.fromCircle(center: rightHolePosition, radius: holeRadius));
//   }

//   void _initCenterWindow() {
//     Rect centerWindow = Rect.fromLTRB(
//       size.width * 0.4,
//       size.height * 0.37,
//       size.width * 0.6,
//       size.height * 0.55,
//     );
//     centerWindowPath = Path()..addRect(centerWindow);
//   }

//   void _drawTape() {
//     // Determine theme brightness from the context (or pass it down)
//     // For CustomPainter, it's typical to pass theme data if needed.
//     // Assuming a dark-ish tape regardless of app theme for authenticity
//     final gradient = LinearGradient(
//       colors: [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     final tapeRect = Rect.fromLTRB(0, 0, size.width, size.height);
//     paintObject.shader = gradient.createShader(tapeRect);

//     RRect tape = RRect.fromRectAndRadius(tapeRect, const Radius.circular(16));
//     Path tapePath = Path()..addRRect(tape);

//     tapePath = _cutHolesIntoPath(tapePath);
//     tapePath = _cutCenterWindowIntoPath(tapePath);

//     canvas.drawShadow(tapePath, Colors.black, 3.0, false);
//     canvas.drawPath(tapePath, paintObject);
//     paintObject.shader = null; // Reset shader
//   }

//   Path _cutCenterWindowIntoPath(Path path) {
//     return Path.combine(PathOperation.difference, path, centerWindowPath);
//   }

//   Path _cutHolesIntoPath(Path path) {
//     path = Path.combine(PathOperation.difference, path, leftHole);
//     path = Path.combine(PathOperation.difference, path, rightHole);
//     return path;
//   }

//   void _drawTapeLabel() {
//     // Assuming a light-colored label inside the dark tape
//     final labelColor = const Color(0xFFDDD6C8);
//     final labelTopColor = const Color(0xFFEF5350); // Red stripe

//     double labelPadding = size.width * 0.05;
//     Rect label = Rect.fromLTWH(labelPadding, labelPadding,
//         size.width - labelPadding * 2, size.height * 0.7);
//     Path labelPath = Path()..addRect(label);
//     labelPath = _cutHolesIntoPath(labelPath);
//     labelPath = _cutCenterWindowIntoPath(labelPath);

//     Rect labelTop = Rect.fromLTRB(
//       label.left,
//       label.top + label.height * 0.2,
//       label.right,
//       label.bottom - label.height * 0.1,
//     );
//     Path labelTopPath = Path()..addRect(labelTop);
//     labelTopPath = _cutHolesIntoPath(labelTopPath);
//     labelTopPath = _cutCenterWindowIntoPath(labelTopPath);

//     paintObject.color = labelColor;
//     canvas.drawPath(labelPath, paintObject);
//     paintObject.color = labelTopColor;
//     canvas.drawPath(labelTopPath, paintObject);
//   }

//   void _drawCenterWindow() {
//     final glassGradient = LinearGradient(
//       colors: [Colors.black38, Colors.black12],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );
//     paintObject.shader =
//         glassGradient.createShader(centerWindowPath.getBounds());
//     canvas.drawPath(centerWindowPath, paintObject);
//     paintObject.shader = null;
//   }

//   void _drawBlackRect() {
//     Rect blackRect = Rect.fromLTWH(size.width * 0.2, size.height * 0.31,
//         size.width * 0.6, size.height * 0.3);
//     Path blackRectPath = Path()..addRRect(RRect.fromRectXY(blackRect, 4, 4));

//     blackRectPath =
//         Path.combine(PathOperation.difference, blackRectPath, leftHole);
//     blackRectPath =
//         Path.combine(PathOperation.difference, blackRectPath, rightHole);
//     blackRectPath = _cutCenterWindowIntoPath(blackRectPath);

//     paintObject.color = const Color.fromRGBO(0, 0, 0, 0.8);
//     canvas.drawPath(blackRectPath, paintObject);
//   }

//   void _drawHoleRing() {
//     Path leftHoleRing = Path()
//       ..addOval(
//           Rect.fromCircle(center: leftHolePosition, radius: holeRadius * 1.1));
//     Path rightHoleRing = Path()
//       ..addOval(
//           Rect.fromCircle(center: rightHolePosition, radius: holeRadius * 1.1));

//     leftHoleRing =
//         Path.combine(PathOperation.difference, leftHoleRing, leftHole);
//     rightHoleRing =
//         Path.combine(PathOperation.difference, rightHoleRing, rightHole);

//     paintObject.color = Colors.white; // Ring color is white for contrast
//     canvas.drawPath(leftHoleRing, paintObject);
//     canvas.drawPath(rightHoleRing, paintObject);
//   }

//   void _drawTextLabel() {
//     final textStyle = TextStyle(
//       color: Colors.black, // Text inside the tape label is black
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//       shadows: const [
//         Shadow(blurRadius: 2, color: Colors.white, offset: Offset(0.5, 0.5))
//       ],
//     );
//     final span = TextSpan(style: textStyle, text: title);
//     final textPainter =
//         TextPainter(text: span, textDirection: TextDirection.ltr);

//     textPainter.layout();

//     final RRect tape = RRect.fromRectAndRadius(
//       Rect.fromLTRB(0, 0, size.width, size.height),
//       const Radius.circular(16),
//     );

//     canvas.save();
//     canvas.clipRRect(tape);

//     final double totalScrollWidth = textPainter.width + 80;
//     final double scrollOffset = (rotationValue) * 200;

//     double x = -scrollOffset;
//     double y = size.height * 0.12;

//     while (x < size.width) {
//       textPainter.paint(canvas, Offset(x, y));
//       x += totalScrollWidth;
//     }

//     canvas.restore();
//   }

//   void _drawTapePins() {
//     paintObject.color = Colors.white;
//     final int pinCount = 8;

//     for (var i = 0; i < pinCount; i++) {
//       _drawTapePin(leftHolePosition, rotationValue + i / pinCount);
//       _drawTapePin(rightHolePosition, rotationValue + i / pinCount);
//     }
//   }

//   void _drawTapePin(Offset center, double angle) {
//     _drawRotated(center, -angle, () {
//       canvas.drawRect(
//         Rect.fromLTWH(center.dx - 2, center.dy - holeRadius, 4, holeRadius / 4),
//         paintObject,
//       );
//     });
//   }

//   void _drawRotated(Offset center, double angle, Function drawFunction) {
//     canvas.save();
//     canvas.translate(center.dx, center.dy);
//     canvas.rotate(angle * pi * 2);
//     canvas.translate(-center.dx, -center.dy);
//     drawFunction();
//     canvas.restore();
//   }

//   void _drawTapeReels() {
//     Path leftTapeRoll = Path()
//       ..addOval(Rect.fromCircle(
//           center: leftHolePosition, radius: holeRadius * (1 - progress) * 5));
//     Path rightTapeRoll = Path()
//       ..addOval(Rect.fromCircle(
//           center: rightHolePosition, radius: holeRadius * progress * 5));

//     leftTapeRoll =
//         Path.combine(PathOperation.difference, leftTapeRoll, leftHole);
//     rightTapeRoll =
//         Path.combine(PathOperation.difference, rightTapeRoll, rightHole);

//     paintObject.color = Colors.black; // Tape reel color is black
//     canvas.drawPath(leftTapeRoll, paintObject);
//     canvas.drawPath(rightTapeRoll, paintObject);
//   }

//   void _drawTopGloss() {
//     paintObject.color =
//         const Color.fromRGBO(0, 0, 0, 0.05); // Subtle gloss effect
//     final gloss = Path()
//       ..moveTo(0, 0)
//       ..quadraticBezierTo(size.width / 2, size.height * 0.15, size.width, 0)
//       ..lineTo(size.width, size.height * 0.05)
//       ..quadraticBezierTo(
//           size.width / 2, size.height * 0.2, 0, size.height * 0.05)
//       ..close();
//     canvas.drawPath(gloss, paintObject);
//   }
// }
