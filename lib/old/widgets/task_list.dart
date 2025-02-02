import 'package:edu_app/old/enums/task.dart';
import 'package:edu_app/old/widgets/task.dart';
import 'package:flutter/material.dart';

class TasksList extends StatelessWidget {
  final String avatar;

  const TasksList({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Task(
              subject: TaskSubject.math,
              priority: TaskPriority.high,
              status: TaskStatus.todo,
              title: 'The task',
              description: 'Description',
              dateTime: DateTime.now(),
              assignorAvatar: index / 2 == 0 ? null : avatar,
              assigneeAvatarList: List.filled(7, avatar),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
