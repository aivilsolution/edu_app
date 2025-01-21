import 'package:edu_app/functions/get_month_name.dart';
import 'package:edu_app/widgets/build_pill.dart';
import 'package:edu_app/widgets/avatar_list.dart';
import 'package:flutter/material.dart';
import 'package:edu_app/enums/task.dart';

class Task extends StatelessWidget {
  final TaskSubject subject;
  final TaskPriority priority;
  final TaskStatus status;
  final String title;
  final String description;
  final DateTime dateTime;
  final String? assignorAvatar;
  final List<String> assigneeAvatarList;

  const Task({
    super.key,
    required this.subject,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    required this.dateTime,
    this.assignorAvatar,
    this.assigneeAvatarList = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (assignorAvatar != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(
                color: Colors.white.withAlpha(51),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'assigned by',
                  style: TextStyle(
                    color: Colors.white.withAlpha(153),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(51),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(assignorAvatar!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: assignorAvatar != null
                ? BorderRadius.vertical(bottom: Radius.circular(12))
                : BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha(51),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BuildPill(text: subject.label),
                  const SizedBox(width: 4),
                  BuildPill(text: priority.label),
                  const Spacer(),
                  BuildPill(text: status.label),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              BuildPill(text: 'Attachments'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dateTime.day} ${getMonthName(dateTime.month)}, ${dateTime.year}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 12,
                    ),
                  ),
                  AvatarList(
                    avatarList: assigneeAvatarList,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
