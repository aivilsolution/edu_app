import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String? name;
  final double fontSize;

  const CourseCard({super.key, this.name, this.fontSize = 16});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            name ?? 'Course Name',
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
