import 'package:flutter/material.dart';
import 'package:tape_player/tape.dart'; // Assuming tape.dart is in lib/tape.dart

class Home extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const Home({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tape Music Player'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: const SafeArea(
        child: Center(
          child: Tape(),
        ),
      ),
    );
  }
}
