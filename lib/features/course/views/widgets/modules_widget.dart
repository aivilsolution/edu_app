
import 'package:edu_app/features/course/models/course_data.dart';
import 'package:flutter/material.dart';

class ModulesWidget extends StatelessWidget {
  final CourseData courseData;

  const ModulesWidget({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        'Assignments',
        '${courseData.assignments.length} items', 
        Icons.assignment,
      ),
      (
        'Quizzes',
        '${courseData.quizzes.length} items', 
        Icons.quiz,
      ),
      (
        'Labs',
        '${courseData.labs.length} items',
        Icons.science,
      ), 
      (
        'Documents',
        '${courseData.documents.length} files',
        Icons.library_books,
      ), 
      (
        'Syllabus',
        '${courseData.syllabus.length} sections',
        Icons.menu_book,
      ), 
      
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
      elevation: 2, 
      color: Theme.of(context).cardColor, 
      child: InkWell(
        
        borderRadius: BorderRadius.circular(4), 
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ), 
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ), 
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ), 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
