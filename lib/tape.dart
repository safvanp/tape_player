// tape.dart
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:marquee/marquee.dart';
import 'package:tape_player/tape/tape_button.dart';
import 'package:tape_player/tape/tape_painter.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum TapeStatus { initial, playing, pausing, stopping, choosing }

enum RepeatMode { none, one, all }

bool showPlaylist = false;
RepeatMode repeatMode = RepeatMode.none;

class Tape extends StatefulWidget {
  const Tape({super.key});

  @override
  State<Tape> createState() => _TapeState();
}

class _TapeState extends State<Tape> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late AudioPlayer audioPlayer;

  TapeStatus tapeStatus = TapeStatus.initial;
  List<PlatformFile> playlist = [];
  int currentIndex = 0;
  String? title;
  double currentPosition = 0.0;
  int totalDurationValue = 0;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;

  // New state variable to track if an initial scan/load has occurred
  bool _hasScannedOrLoaded = false; // Changed name for clarity

  // Reference to the Hive box
  late Box<List<String>> _musicBox;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    )..addListener(() => setState(() {}));

    audioPlayer = AudioPlayer();

    audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        currentDuration = position;
        currentPosition = totalDurationValue > 0
            ? position.inMilliseconds / totalDurationValue
            : 0.0;
      });
    });

    audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        totalDuration = duration;
        totalDurationValue = duration.inMilliseconds;
      });
    });

    audioPlayer.onPlayerComplete.listen((_) {
      _handlePlayerComplete();
    });

    // Get the Hive box reference
    _musicBox = Hive.box<List<String>>('music_playlist_box');
    _loadPlaylistFromStorage(); // Attempt to load playlist on startup
  }

  /// Handles the logic when a track completes playback based on the current repeat mode.
  void _handlePlayerComplete() {
    switch (repeatMode) {
      case RepeatMode.one:
        play(); // Replay the current track
        break;
      case RepeatMode.all:
        currentIndex = (currentIndex + 1) % playlist.length;
        play();
        break;
      case RepeatMode.none:
        if (currentIndex < playlist.length - 1) {
          next();
        } else {
          stop();
        }
        break;
    }
  }

  /// Loads the saved playlist from Hive storage.
  Future<void> _loadPlaylistFromStorage() async {
    final storedPaths = _musicBox.get('playlist_paths'); // Get paths from box
    if (storedPaths != null && storedPaths.isNotEmpty) {
      // Reconstruct PlatformFile objects from stored paths
      List<PlatformFile> loadedFiles = storedPaths
          .map((path) => PlatformFile(
                name: path.split('/').last, // Simple name extraction
                path: path,
                size: 0, // Size is not crucial for playback, can be 0
              ))
          .toList();

      setState(() {
        playlist = loadedFiles;
        _hasScannedOrLoaded = true; // Mark that content has been loaded
        currentIndex = 0; // Start with the first song
      });
      play(); // Auto-play the first song
    } else {
      // If nothing found in storage, mark as not scanned/loaded yet
      setState(() {
        _hasScannedOrLoaded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show the "Scan Device" button if no playlist has been loaded/scanned yet
    if (!_hasScannedOrLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Tape Music Player!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              // This button triggers the file picker for the initial scan
              onPressed: () => choose(isInitialScan: true),
              icon: const Icon(Icons.folder_open),
              label: const Text('Scan Device for Music'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Otherwise, show the main tape player UI
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tape Display Area
            SizedBox(
              width: 300,
              height: 200,
              child: CustomPaint(
                painter: TapePainter(
                  rotationValue: animationController.value,
                  title: title ?? '',
                  progress: currentPosition,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TapeButton(
                    icon: Icons.skip_previous,
                    onTap: previous,
                    isTapped: false),
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
                    icon: Icons.folder_open, // Regular button to add more music
                    onTap: () => choose(isInitialScan: false),
                    isTapped: tapeStatus == TapeStatus.choosing),
                TapeButton(icon: Icons.skip_next, onTap: next, isTapped: false),
              ],
            ),
            const SizedBox(height: 10),

            // Scrolling Title Display
            SizedBox(
              height: 30,
              width: 300,
              child: Marquee(
                text: title ?? "No track selected",
                style: const TextStyle(fontSize: 10),
                scrollAxis: Axis.horizontal,
                blankSpace: 40.0,
                velocity: 30.0,
                pauseAfterRound: const Duration(seconds: 1),
                startPadding: 10.0,
              ),
            ),

            // Progress Slider and Duration Text
            SizedBox(
              width: 300,
              height: 80,
              child: Column(
                children: [
                  Slider(
                    min: 0.0,
                    max: totalDuration.inMilliseconds.toDouble(),
                    value: currentDuration.inMilliseconds
                        .clamp(0.0, totalDuration.inMilliseconds.toDouble())
                        .toDouble(),
                    onChanged: (value) {
                      final position = Duration(milliseconds: value.toInt());
                      audioPlayer.seek(position);
                    },
                  ),
                  Text(
                    "${_formatDuration(currentDuration)} / ${_formatDuration(totalDuration)}",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),

            // Playlist and Repeat Mode Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(showPlaylist
                      ? Icons.playlist_add_check
                      : Icons.playlist_play),
                  onPressed: () => setState(() => showPlaylist = !showPlaylist),
                ),
                IconButton(
                  icon: Icon(_repeatIcon()),
                  onPressed: _toggleRepeatMode,
                ),
              ],
            ),

            // Conditional Playlist Widget Display
            _buildPlaylist(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylist() {
    if (!showPlaylist || playlist.isEmpty) return const SizedBox.shrink();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 300,
      height: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromRGBO(0, 0, 0, 0.85)
            : const Color.fromRGBO(240, 240, 240, 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final file = playlist[index];
            final isSelected = index == currentIndex;

            final textColor = isDarkMode
                ? (isSelected ? Colors.amber : Colors.white)
                : (isSelected ? Colors.blue.shade700 : Colors.black87);
            final tileColor = isDarkMode
                ? (isSelected ? Colors.grey.shade800 : Colors.transparent)
                : (isSelected ? Colors.blue.shade50 : Colors.transparent);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              tileColor: tileColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                setState(() => currentIndex = index);
                play();
              },
            );
          },
          separatorBuilder: (_, __) => Divider(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
            thickness: 0.8,
            indent: 12,
            endIndent: 12,
          ),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
        ),
      ),
    );
  }

  IconData _repeatIcon() {
    switch (repeatMode) {
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
      default:
        return Icons.repeat_on_outlined;
    }
  }

  void _toggleRepeatMode() {
    setState(() {
      switch (repeatMode) {
        case RepeatMode.none:
          repeatMode = RepeatMode.one;
          break;
        case RepeatMode.one:
          repeatMode = RepeatMode.all;
          break;
        case RepeatMode.all:
          repeatMode = RepeatMode.none;
          break;
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void stop() {
    animationController.stop();
    audioPlayer.stop();
    setState(() {
      tapeStatus = TapeStatus.stopping;
      currentPosition = 0.0;
      currentDuration = Duration.zero;
      totalDuration = Duration.zero;
      totalDurationValue = 0;
    });
  }

  void pause() {
    animationController.stop();
    audioPlayer.pause();
    setState(() => tapeStatus = TapeStatus.pausing);
  }

  Future<void> play() async {
    if (playlist.isEmpty || currentIndex >= playlist.length) {
      stop();
      return;
    }

    try {
      final path = playlist[currentIndex].path!;
      await audioPlayer.setSourceDeviceFile(path);

      setState(() {
        tapeStatus = TapeStatus.playing;
      });

      await audioPlayer.resume();
      animationController.repeat();

      final info = await MetadataRetriever.fromFile(File(path));
      setState(() => title = _buildTitle(info));
    } catch (ex) {
      debugPrint("Play error: $ex");
    }
  }

  String _buildTitle(Metadata info) {
    var base = 'Artist: ${info.albumArtistName ?? 'Unknown Artist'} '
        'Album: ${info.albumName ?? playlist[currentIndex].name}';

    if (info.trackArtistNames != null && info.trackArtistNames!.isNotEmpty) {
      base += ' (Artists: ${info.trackArtistNames!.join(', ')})';
    }

    if (info.year != null) {
      base += ' Year: ${info.year}';
    }

    return base;
  }

  void next() {
    if (playlist.isEmpty) return;
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      play();
    } else {
      if (repeatMode == RepeatMode.all) {
        currentIndex = 0;
        play();
      } else {
        stop();
      }
    }
  }

  void previous() {
    if (playlist.isEmpty) return;
    if (currentIndex > 0) {
      currentIndex--;
      play();
    }
  }

  /// Opens a file picker to choose audio files for the playlist.
  /// If `isInitialScan` is true, it marks the first time picking.
  Future<void> choose({bool isInitialScan = false}) async {
    stop();
    setState(() => tapeStatus = TapeStatus.choosing);

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.audio,
    );

    if (result == null) {
      setState(() {
        // If cancelled, and it was the initial scan, ensure the "Scan Device" button remains
        if (isInitialScan && playlist.isEmpty) {
          _hasScannedOrLoaded = false;
        }
        tapeStatus = TapeStatus.initial; // Revert status
      });
      return;
    }

    setState(() {
      playlist = result.files;
      currentIndex = 0;
      _hasScannedOrLoaded = true; // Mark that content has been picked/loaded
    });

    // Save selected file paths to Hive for persistence
    final pathsToSave = playlist.map((file) => file.path!).toList();
    await _musicBox.put('playlist_paths', pathsToSave);

    play(); // Start playing the first track
  }

  @override
  void dispose() {
    animationController.dispose();
    audioPlayer.dispose();
    _musicBox.close(); // Close the Hive box when the widget is disposed
    super.dispose();
  }
}
