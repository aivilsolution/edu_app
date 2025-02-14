import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/date_selector.dart';
import '../widgets/hour_list.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
  }

  void _onDaySelected(DateTime selectedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = selectedDay;
      });
    }
  }

  Future<void> _showCalendarDialog() async {
    final DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    Navigator.of(context).pop(selectedDay);
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDate != null) {
      _onDaySelected(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DateSelector(
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              onTap: _showCalendarDialog,
              onDateSelected: _onDaySelected,
            ),
            HourList(
              selectedDay: _selectedDay,
              onDateSelected: _onDaySelected,
            ),
          ],
        ),
      ),
    );
  }
}
