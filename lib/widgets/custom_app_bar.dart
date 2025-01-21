import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final String? text;
  const CustomAppBar({super.key, required this.actions, this.text});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      title: Text(
        text ?? "Educational app",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
    );
  }
}
