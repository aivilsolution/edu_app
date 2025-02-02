import 'package:flutter/material.dart';

class GridWidget extends StatelessWidget {
  final List<Widget> items;
  final int columns;
  final double spacing;
  final GestureTapCallback? onTap;

  const GridWidget({
    super.key,
    required this.items,
    this.columns = 2,
    this.spacing = 16.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: onTap,
          child: Card(
            child: items[index],
          ),
        );
      },
    );
  }
}
