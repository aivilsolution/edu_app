import 'package:flutter/material.dart';
import 'package:edu_app/enums/task.dart';

class Task extends StatelessWidget {
  final TaskSubject subject;
  final TaskPriority priority;
  final TaskStatus status;
  final String title;
  final String description;
  final DateTime dateTime;
  final String? assignorAvatarUrl;
  final List<String> assigneeAvatarUrls;

  const Task({
    super.key,
    required this.subject,
    required this.priority,
    required this.status,
    required this.title,
    required this.description,
    required this.dateTime,
    this.assignorAvatarUrl,
    this.assigneeAvatarUrls = const [],
  });

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(51),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withAlpha(204),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAssignees() {
    final displayedMembers = assigneeAvatarUrls.take(3).toList();
    final remainingCount = assigneeAvatarUrls.length - displayedMembers.length;
    const double avatarSize = 32;
    final double stackWidth = displayedMembers.length * (avatarSize * 0.7) +
        (remainingCount > 0 ? avatarSize : 0);

    return SizedBox(
      width: stackWidth + avatarSize * 0.1,
      height: avatarSize,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          for (var i = 0; i < displayedMembers.length; i++)
            Positioned(
              left: i * (avatarSize * 0.7),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1.5,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(displayedMembers[i]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          if (remainingCount > 0)
            Positioned(
              left: displayedMembers.length * (avatarSize * 0.7),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.white.withAlpha(51),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (assignorAvatarUrl != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade900, // Changed only this color

              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(51),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(assignorAvatarUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border.all(
              color: Colors.white.withAlpha(51),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildPill(subject.label),
                  const SizedBox(width: 8),
                  _buildPill(priority.label),
                  const Spacer(),
                  _buildPill(status.label),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildPill('Attachments'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${dateTime.day} ${_getMonthName(dateTime.month)}, ${dateTime.year}',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                  _buildAssignees(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
