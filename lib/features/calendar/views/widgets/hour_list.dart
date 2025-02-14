import 'package:edu_app/core/constants/calendar_constants.dart';
import 'package:edu_app/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HourList extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDateSelected;

  const HourList({
    super.key,
    required this.selectedDay,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: CalendarConstants.totalHours,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final hourDateTime = DateTime(
            selectedDay.year,
            selectedDay.month,
            selectedDay.day,
            index,
          );
          final isCurrentHour = checkIsCurrentHour(selectedDay, index);

          return HourItem(
            hourDateTime: hourDateTime,
            isCurrentHour: isCurrentHour,
          );
        },
      ),
    );
  }
}

class HourItem extends StatelessWidget {
  const HourItem({
    required this.hourDateTime,
    required this.isCurrentHour,
  });

  final DateTime hourDateTime;
  final bool isCurrentHour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedHour = DateFormat('h a').format(hourDateTime);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final onPrimaryColor = theme.colorScheme.onPrimary;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: CalendarConstants.hourItemSpacing,
      ),
      decoration: BoxDecoration(
        color: isCurrentHour ? primaryColor.withOpacity(0.1) : surfaceColor,
        borderRadius: BorderRadius.circular(
          CalendarConstants.smallBorderRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(CalendarConstants.hourItemPadding),
        child: Row(
          children: [
            TimeContainer(
              formattedHour: formattedHour,
              isCurrentHour: isCurrentHour,
              primaryColor: primaryColor,
              onPrimaryColor: onPrimaryColor,
            ),
            if (isCurrentHour) ...[
              const SizedBox(width: 12),
              CurrentTimeIndicator(primaryColor: primaryColor),
            ],
          ],
        ),
      ),
    );
  }
}

class TimeContainer extends StatelessWidget {
  const TimeContainer({
    super.key,
    required this.formattedHour,
    required this.isCurrentHour,
    required this.primaryColor,
    required this.onPrimaryColor,
  });

  final String formattedHour;
  final bool isCurrentHour;
  final Color primaryColor;
  final Color onPrimaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CalendarConstants.timeContainerWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isCurrentHour ? primaryColor : primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formattedHour,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isCurrentHour ? onPrimaryColor : primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class CurrentTimeIndicator extends StatelessWidget {
  const CurrentTimeIndicator({
    super.key,
    required this.primaryColor,
  });

  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Current Time',
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
