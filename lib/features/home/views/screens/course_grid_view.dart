import '/features/course/views/screens/course_page.dart';
import '/shared/widgets/course_card.dart';
import 'package:flutter/material.dart';
import '/features/course/models/sample_data.dart';

class CoursesGridView extends StatelessWidget {
  final int crossAxisCount;
  final double spacing;

  const CoursesGridView({
    super.key,
    this.crossAxisCount = 2,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Courses",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 1,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CoursePage(course: courses[index]),
              ),
            ),
            child: CourseCard(name: courses[index].name, fontSize: 18),
          );
        },
      ),
    );
  }
}
