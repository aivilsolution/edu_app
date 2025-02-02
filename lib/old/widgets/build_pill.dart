import 'package:flutter/material.dart';

class BuildPill extends StatelessWidget {
  const BuildPill({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(51),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withAlpha(204),
          fontSize: 12,
        ),
      ),
    );
  }
}
