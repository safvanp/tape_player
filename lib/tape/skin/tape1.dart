import 'dart:math';
import 'package:flutter/material.dart';

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CassetteAudioPlayer extends StatefulWidget {
  @override
  _CassetteAudioPlayerState createState() => _CassetteAudioPlayerState();
}

class _CassetteAudioPlayerState extends State<CassetteAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer audioPlayer;
  late AnimationController _controller;
  bool isPlaying = false;

  final String audioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'; // Replace with your audio

  @override
  void initState() {
    super.initState();

    audioPlayer = AudioPlayer();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() => setState(() {}));

    // Listen to audio player state
    audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
        if (isPlaying) {
          _controller.repeat();
        } else {
          _controller.stop();
        }
      });
    });
  }

  void _togglePlay() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play(UrlSource(audioUrl));
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(320, 200),
              painter:
                  CassettePainter(rotationValue: _controller.value * 2 * pi),
            ),
            Positioned(
              bottom: 40,
              child: ElevatedButton.icon(
                onPressed: _togglePlay,
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(isPlaying ? 'Pause' : 'Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CassettePainter extends CustomPainter {
  final double rotationValue;

  CassettePainter({required this.rotationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double reelRadius = 30;
    final Offset leftCenter = Offset(size.width * 0.3, size.height * 0.55);
    final Offset rightCenter = Offset(size.width * 0.7, size.height * 0.55);

    // Cassette body
    final Paint bodyPaint = Paint()..color = Colors.black;
    final RRect body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(12),
    );
    canvas.drawRRect(body, bodyPaint);

    // Label area
    final Paint labelPaint = Paint()..color = Colors.white;
    final Rect labelRect =
        Rect.fromLTWH(size.width * 0.2, 20, size.width * 0.6, 30);
    canvas.drawRect(labelRect, labelPaint);

    final textPainter = TextPainter(
      text: TextSpan(
          text: 'SIDE A',
          style: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.2 + 8, 26));

    // Clear cassette window
    final Paint windowPaint = Paint()..color = Colors.white.withOpacity(0.1);
    final Rect windowRect =
        Rect.fromLTWH(size.width * 0.15, 60, size.width * 0.7, 70);
    canvas.drawRRect(
        RRect.fromRectAndRadius(windowRect, Radius.circular(6)), windowPaint);

    // Tape path
    final Paint tapePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4;
    canvas.drawLine(leftCenter, rightCenter, tapePaint);

    // Reels
    _drawReel(canvas, leftCenter, reelRadius, rotationValue);
    _drawReel(canvas, rightCenter, reelRadius, rotationValue);

    // Screws
    final Paint screwPaint = Paint()..color = Colors.grey[400]!;
    final double screwRadius = 3.5;
    final List<Offset> screwPositions = [
      Offset(12, 12),
      Offset(size.width - 12, 12),
      Offset(12, size.height - 12),
      Offset(size.width - 12, size.height - 12),
    ];
    for (var pos in screwPositions) {
      canvas.drawCircle(pos, screwRadius, screwPaint);
    }
  }

  void _drawReel(Canvas canvas, Offset center, double radius, double rotation) {
    final Paint hubPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint markerPaint = Paint()
      ..color = const Color(0xFFDD4A1F)
      ..style = PaintingStyle.fill;

    final Paint strokePaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw reel hub
    canvas.drawCircle(center, radius, hubPaint);

    // Draw rotating markers
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    const int markerCount = 6;
    final double markerHeight = radius * 1.1;
    final double markerWidth = radius * 0.4;

    for (int i = 0; i < markerCount; i++) {
      final Path path = Path();
      path.moveTo(0, -markerHeight / 2);
      path.quadraticBezierTo(-markerWidth / 2, 0, 0, markerHeight / 2);
      path.quadraticBezierTo(markerWidth / 2, 0, 0, -markerHeight / 2);

      canvas.drawPath(path, markerPaint);
      canvas.drawPath(path, strokePaint);
      canvas.rotate(2 * pi / markerCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
