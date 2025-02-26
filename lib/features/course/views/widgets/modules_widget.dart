import '/features/course/models/course_model.dart';
import 'package:flutter/material.dart';

class ModulesWidget extends StatelessWidget {
  final Course course;

  const ModulesWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        'Assignments',
        '${course.assignments.where((a) => !a.isSubmitted).length} pending',
        Icons.assignment
      ),
      (
        'Quizzes',
        '${course.quizzes.where((q) => !q.isCompleted).length} upcoming',
        Icons.quiz
      ),
      ('Labs', '${course.labs.length} scheduled', Icons.science),
      ('Resources', 'View Materials', Icons.library_books),
      ('Syllabus', 'Course Overview', Icons.menu_book),
      ('Contact', 'Professor', Icons.contact_mail),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _FeatureCard(
          title: features[index].$1,
          subtitle: features[index].$2,
          icon: features[index].$3,
        );
      },
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
