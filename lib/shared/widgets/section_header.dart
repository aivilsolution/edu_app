import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAction;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    required this.onAction,
    this.actionIcon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        IconButton(icon: Icon(actionIcon), onPressed: onAction),
      ],
    );
  }
}
