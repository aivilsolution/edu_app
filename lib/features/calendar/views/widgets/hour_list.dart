import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Displays a scrollable list of hours with a timeline background.
class HourList extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDateSelected;
  final int totalHours;

  const HourList({
    super.key,
    required this.selectedDay,
    required this.onDateSelected,
    this.totalHours = 24,
  });

  static const double horizontalPadding = 24.0;
  static const double topPadding = 16.0;
  static const double bottomPadding = 16.0;
  static const double timeContainerWidth = 100.0;
  static const double itemHeight = 80.0;
  static const double dotSize = 12.0;

  @override
  Widget build(BuildContext context) {
    // Calculate overall height for the timeline background.
    final contentHeight = totalHours * itemHeight + topPadding + bottomPadding;

    // Cache the current time once to avoid multiple DateTime.now() calls.
    final now = DateTime.now();

    return Expanded(
      child: SingleChildScrollView(
        child: SizedBox(
          height: contentHeight,
          child: Stack(
            children: [
              // Timeline background with line and dots.
              Positioned.fill(
                child: CustomPaint(
                  painter: TimelinePainter(
                    topPadding: topPadding,
                    bottomPadding: bottomPadding,
                    totalHours: totalHours,
                    itemHeight: itemHeight,
                    horizontalOffset: horizontalPadding + timeContainerWidth,
                    dotSize: dotSize,
                    lineColor: Colors.grey.shade300,
                    dotColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              // List of hour items.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: topPadding,
                ),
                child: Column(
                  children: List.generate(totalHours, (index) {
                    final hourDateTime = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                      index,
                    );

                    // Determine if this hour is the current hour.
                    final isCurrentHour =
                        (hourDateTime.hour == now.hour) &&
                        (selectedDay.year == now.year) &&
                        (selectedDay.month == now.month) &&
                        (selectedDay.day == now.day);

                    return SizedBox(
                      height: itemHeight,
                      child: HourItem(
                        hourDateTime: hourDateTime,
                        isCurrentHour: isCurrentHour,
                        onTap: () => onDateSelected(hourDateTime),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double topPadding;
  final double bottomPadding;
  final int totalHours;
  final double itemHeight;
  final double horizontalOffset;
  final double dotSize;
  final Color lineColor;
  final Color dotColor;

  TimelinePainter({
    required this.topPadding,
    required this.bottomPadding,
    required this.totalHours,
    required this.itemHeight,
    required this.horizontalOffset,
    required this.dotSize,
    required this.lineColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Define the line width.
    const double lineWidth = 2.0;

    // Calculate the vertical boundaries for the line.
    final double lineTop = topPadding;
    final double lineBottom = size.height - bottomPadding;

    // Instead of drawLine, draw a centered rectangle for a crisper line.
    final double lineLeft = horizontalOffset - lineWidth / 2;
    final Rect lineRect = Rect.fromLTWH(
      lineLeft,
      lineTop,
      lineWidth,
      lineBottom - lineTop,
    );
    final Paint linePaint = Paint()..color = lineColor;
    canvas.drawRect(lineRect, linePaint);

    // Draw dots at each hour.
    final Paint dotPaint = Paint()..color = dotColor;
    for (int i = 0; i < totalHours; i++) {
      final double dotCenterY = topPadding + i * itemHeight + itemHeight / 2;
      final Offset dotCenter = Offset(horizontalOffset, dotCenterY);
      canvas.drawCircle(dotCenter, dotSize / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) =>
      oldDelegate.totalHours != totalHours ||
      oldDelegate.itemHeight != itemHeight ||
      oldDelegate.horizontalOffset != horizontalOffset ||
      oldDelegate.dotSize != dotSize ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor;
}

/// Represents an individual hour entry.
class HourItem extends StatelessWidget {
  final DateTime hourDateTime;
  final bool isCurrentHour;
  final VoidCallback onTap;

  const HourItem({
    super.key,
    required this.hourDateTime,
    required this.isCurrentHour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedHour = DateFormat('h a').format(hourDateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          TimeContainer(
            formattedHour: formattedHour,
            isCurrentHour: isCurrentHour,
          ),
          if (isCurrentHour) ...const [
            SizedBox(width: 16),
            CurrentTimeIndicator(),
          ],
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// Displays the formatted hour in a styled container.
class TimeContainer extends StatelessWidget {
  final String formattedHour;
  final bool isCurrentHour;

  const TimeContainer({
    super.key,
    required this.formattedHour,
    required this.isCurrentHour,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onBackgroundColor = theme.colorScheme.onSurface;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return Container(
      width: 86,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentHour ? primaryColor : primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border:
            isCurrentHour
                ? Border.all(color: primaryColor.withValues(alpha: 0.5))
                : null,
      ),
      child: Text(
        formattedHour,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isCurrentHour ? onPrimaryColor : onBackgroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    );
  }
}

/// Indicates the current time.
class CurrentTimeIndicator extends StatelessWidget {
  const CurrentTimeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onBackgroundColor = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 18, color: onBackgroundColor),
          const SizedBox(width: 8),
          Text(
            'Current Time',
            style: theme.textTheme.titleSmall?.copyWith(
              color: onBackgroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
