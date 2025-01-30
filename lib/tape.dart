import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:tape_player/tape/components/tuner_painter.dart';
import 'package:tape_player/tape/tape_button.dart';
import 'package:tape_player/tape/tape_painter.dart';

enum TapeStatus { initial, playing, pausing, stopping, choosing }

class Tape extends StatefulWidget {
  const Tape({super.key});

  @override
  State<Tape> createState() => _TapeState();
}

class _TapeState extends State<Tape> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late AudioPlayer audioPlayer;

  TapeStatus tapeStatus = TapeStatus.initial;
  String? url;
  String? title;
  double currentPosition = 0.0;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    Tween<double> tween = Tween<double>(begin: 0.0, end: 1.0);

    tween.animate(animationController);
    audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 200,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: TapePainter(
                    rotationValue: animationController.value,
                    title: title ?? '',
                    progress: currentPosition),
              );
            },
          ),
        ),
        SizedBox(
          height: 40,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            TapeButton(
                icon: Icons.play_arrow,
                onTap: play,
                isTapped: tapeStatus == TapeStatus.playing),
            TapeButton(
                icon: Icons.pause,
                onTap: pause,
                isTapped: tapeStatus == TapeStatus.pausing),
            TapeButton(
                icon: Icons.stop,
                onTap: stop,
                isTapped: tapeStatus == TapeStatus.stopping),
            TapeButton(
                icon: Icons.eject,
                onTap: choose,
                isTapped: tapeStatus == TapeStatus.choosing),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        // SizedBox(
        //   width: 300,
        //   height: 20,
        //   child: CustomPaint(
        //     painter: TunerPainter(
        //         rotationValue: animationController.value,
        //         progress: currentPosition),
        //   ),
        // ),
        SizedBox(
          width: 300,
          height: 50,
          child: Text('data'),
          // child: Slider(
          //     activeColor: const Color(0xFF7AC9FF),
          //     value: currentPosition,
          //     min: 0.0,
          //     max: totalDuration.toDouble() + 1.0,
          //     onChanged: (double value) {
          //       // playerController.setPositionValue = value;
          //     }),
        ),
      ],
    );
  }

  void stop() {
    setState(() {
      tapeStatus = TapeStatus.stopping;
      currentPosition = 0.0;
    });
    animationController.stop();
    audioPlayer.stop();
  }

  void pause() {
    setState(() {
      tapeStatus = TapeStatus.pausing;
    });
    animationController.stop();
    audioPlayer.pause();
  }

  void play() async {
    if (url == null) {
      return;
    }
    setState(() {
      tapeStatus = TapeStatus.playing;
    });
    animationController.repeat();
    audioPlayer.play(UrlSource(url!));
  }

  int totalDuration = 0;

  Future<void> choose() async {
    stop();
    setState(() {
      tapeStatus = TapeStatus.choosing;
    });

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result == null) {
      return;
    }

    PlatformFile file = result.files.first;

    url = file.path;
    audioPlayer.setSourceUrl(url!);

    final info = await MetadataRetriever.fromFile(File(url!));

    int? duration = info.trackDuration;

    file.path.toString().split('/').last;
    String? _title = file.path.toString().split('/').last;
    String? artist;

    if (info.toJson().isNotEmpty) {
      _title = info.albumName;
      artist = info.albumArtistName;
    }
    totalDuration = duration!;

    String? completeTitle = artist == null ? title : '$artist - $_title';

    audioPlayer.onPlayerComplete.listen((event) {
      stop();
    });

    audioPlayer.onPositionChanged.listen(
      (event) {
        currentPosition = event.inMilliseconds / duration!;
      },
    );

    setState(() {
      title = completeTitle;
      tapeStatus = TapeStatus.initial;
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
