import 'package:edu_app/core/constants/calendar_constants.dart';
import 'package:edu_app/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class HourList extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDateSelected;
  const HourList({
    super.key,
    required this.selectedDay,
    required this.onDateSelected,
  });

  String _formatHour(int hour) {
    String period = hour >= 12 ? 'PM' : 'AM';
    int formattedHour = hour % 12;
    formattedHour = formattedHour == 0 ? 12 : formattedHour;
    return '$formattedHour $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: ListView.builder(
        itemCount: CalendarConstants.totalHours,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final isCurrentHour = checkIsCurrentHour(selectedDay, index);
          return Container(
            margin: EdgeInsets.symmetric(
              vertical: CalendarConstants.hourItemSpacing,
            ),
            decoration: BoxDecoration(
              color: isCurrentHour
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(
                CalendarConstants.smallBorderRadius,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(CalendarConstants.hourItemPadding),
              child: Row(
                children: [
                  Container(
                    width: CalendarConstants.timeContainerWidth,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentHour
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatHour(index),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isCurrentHour
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isCurrentHour) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Current Time',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
