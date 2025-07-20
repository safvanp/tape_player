// tape_button.dart
import 'package:flutter/material.dart';

class TapeButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isTapped;

  const TapeButton({
    required this.icon,
    required this.onTap,
    this.isTapped = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Get current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: isTapped ? 44 : 50,
        height: isTapped ? 44 : 50,
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color.fromRGBO(0, 0, 0, 0.9)
              : Colors.grey.shade300, // Adjust color based on theme
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black87
                  : Colors.grey.shade500, // Adjust shadow color
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
            BoxShadow(
              color: isDarkMode
                  ? Colors.grey.shade800
                  : Colors.white, // Adjust shadow color
              blurRadius: 2,
              offset: const Offset(-2, -2),
              spreadRadius: -2,
            ),
          ],
          border: Border.all(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400,
              width: 1), // Adjust border color
        ),
        child: Center(
          child: Icon(
            icon,
            color: isDarkMode
                ? Colors.white
                : Colors.black87, // Adjust icon color based on theme
            size: isTapped ? 20 : 24,
          ),
        ),
      ),
    );
  }
}
