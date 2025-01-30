import 'package:flutter/material.dart';
import 'package:tape_player/tape.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan,
      child: Center(
        child: Tape(),
      ),
    );
  }
}
