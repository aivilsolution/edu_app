import 'package:edu_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class NoVideoWidget extends StatelessWidget {
  
  const NoVideoWidget({super.key});

  @override
  Widget build(BuildContext context) => Container(
    alignment: Alignment.center,
    child: LayoutBuilder(
      builder:
          (ctx, constraints) => Icon(
            Icons.videocam_off_outlined,
            color: AppTheme.seedColor,
            size: math.min(constraints.maxHeight, constraints.maxWidth) * 0.3,
          ),
    ),
  );
}
