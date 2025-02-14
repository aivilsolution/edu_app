import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const SearchWidget({
    Key? key,
    this.hintText = 'Search...',
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          onChanged: onChanged,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: theme.hintColor),
            prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
      ),
    );
  }
}
