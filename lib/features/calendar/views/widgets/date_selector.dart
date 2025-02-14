import 'package:edu_app/core/constants/calendar_constants.dart';
import 'package:edu_app/core/utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final VoidCallback onTap;
  final ValueChanged<DateTime> onDateSelected;

  const DateSelector({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onTap,
    required this.onDateSelected,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late ScrollController _scrollController;
  late List<DateTime> _visibleDays;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _visibleDays =
        generateDaysAround(widget.selectedDay, CalendarConstants.visibleDays);
    WidgetsBinding.instance.addPostFrameCallback(_scrollToSelectedDate);
  }

  @override
  void didUpdateWidget(covariant DateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != oldWidget.selectedDay) {
      _visibleDays =
          generateDaysAround(widget.selectedDay, CalendarConstants.visibleDays);
      WidgetsBinding.instance.addPostFrameCallback(_scrollToSelectedDate);
    }
  }

  void _scrollToSelectedDate(Duration duration) {
    final selectedIndex = _visibleDays.indexWhere(
      (date) => isSameDay(date, widget.selectedDay),
    );

    if (selectedIndex != -1 && _scrollController.hasClients) {
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = CalendarConstants.dateItemWidth +
          2 * CalendarConstants.dateItemSpacing;
      final offset =
          selectedIndex * itemWidth - (screenWidth / 2 - itemWidth / 2);

      _scrollController.animateTo(
        offset.clamp(0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDateItem(
    DateTime date,
    bool isSelected,
    bool isToday,
    ThemeData theme,
  ) {
    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        width: CalendarConstants.dateItemWidth,
        margin: EdgeInsets.symmetric(
          horizontal: CalendarConstants.dateItemSpacing,
          vertical: CalendarConstants.dateItemVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : isToday
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.colorScheme.surface,
          border: isToday && !isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
          borderRadius:
              BorderRadius.circular(CalendarConstants.defaultBorderRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('EEE').format(date),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('d').format(date),
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  BorderRadius.circular(CalendarConstants.largeBorderRadius),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Date',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM yyyy').format(widget.focusedDay),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _visibleDays.length,
            itemBuilder: (context, index) {
              final date = _visibleDays[index];
              final isSelected = isSameDay(date, widget.selectedDay);
              final isToday = isSameDay(date, now);
              return _buildDateItem(date, isSelected, isToday, theme);
            },
          ),
        ),
      ],
    );
  }
}
