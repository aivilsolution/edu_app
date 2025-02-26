import '/features/course/models/course_model.dart';
import 'package:flutter/material.dart';

class ProfessorWidget extends StatelessWidget {
  final Professor professor;

  const ProfessorWidget({super.key, required this.professor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              child: Icon(Icons.person_outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professor.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Office Hours: ${professor.officeHours}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    professor.officeLocation,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
