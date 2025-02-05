List<DateTime> generateDaysAround(DateTime centerDate, int visibleDays) {
  return List.generate(
    visibleDays,
    (index) => centerDate.add(Duration(days: index - (visibleDays ~/ 2))),
  );
}

bool checkIsCurrentHour(DateTime date, int hour) {
  final now = DateTime.now();
  return now.hour == hour &&
      date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}
