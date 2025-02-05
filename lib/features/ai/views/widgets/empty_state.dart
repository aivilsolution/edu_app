import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 100,
            color: theme.dividerColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Start a conversation',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
