import 'package:flutter/material.dart';

class TapeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isTapped;
  const TapeButton(
      {required this.icon,
      required this.onTap,
      this.isTapped = false,
      super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isTapped ? 53.2 : 56,
        height: isTapped ? 60.8 : 64,
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: Center(
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
