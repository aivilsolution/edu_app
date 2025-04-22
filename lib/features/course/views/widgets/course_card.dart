import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String? name;
  final VoidCallback? onTap;
  final double fontSize;
  final int index;
  final Color? color;

  
  static const List<Color> courseColors = [
    Color(0xFF1A73E8), 
    Color(0xFF0F9D58), 
    Color(0xFF7B1FA2), 
    Color(0xFFE65100), 
    Color(0xFFD32F2F), 
  ];

  const CourseCard({
    super.key,
    this.name,
    this.color,
    this.onTap,
    this.fontSize = 16,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    
    final baseColor = color ?? courseColors[index % courseColors.length];

    
    final cardColor =
        isDark
            ? baseColor.withOpacity(0.5)
            : baseColor.withOpacity(0.2); 

    final borderColor =
        isDark
            ? baseColor.withOpacity(0.7)
            : baseColor; 

    
    final List<Color> gradientColors =
        isDark
            ? [
              baseColor.withOpacity(0.35),
              baseColor.withOpacity(0.18),
              baseColor.withOpacity(0.05),
            ]
            : [
              baseColor.withOpacity(0.35), 
              baseColor.withOpacity(0.25),
              baseColor.withOpacity(0.15), 
            ];

    return Card(
      elevation: isDark ? 4 : 2, 
      color: Colors.transparent,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor,
          width: isDark ? 2.0 : 2.5, 
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        splashColor: baseColor.withOpacity(isDark ? 0.3 : 0.4),
        highlightColor: baseColor.withOpacity(isDark ? 0.15 : 0.2),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: gradientColors,
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                name ?? 'Course Name',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  
                  color:
                      isDark
                          ? theme.colorScheme.onSurface
                          : baseColor.withOpacity(
                            0.8,
                          ), 
                  fontSize: fontSize,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
