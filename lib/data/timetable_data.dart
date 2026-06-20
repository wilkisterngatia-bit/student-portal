/// Shared class schedule data. Both the Dashboard (to surface "next
/// class") and the Timetable screen read from this single source so
/// they never drift out of sync with each other.
class ClassSlot {
  final String day;
  final String time;
  final String unit;
  final String room;
  final bool isOnline;

  const ClassSlot(this.day, this.time, this.unit, this.room, {this.isOnline = false});
}

class TimetableData {
  TimetableData._();

  static const List<ClassSlot> slots = [
    ClassSlot('Monday', '08:00 – 10:00', 'BIT 4107 — Mobile App Dev', 'Lab 3'),
    ClassSlot('Monday', '11:00 – 13:00', 'BIT 4102 — Networking', 'Zoom', isOnline: true),
    ClassSlot('Tuesday', '09:00 – 11:00', 'BIT 4105 — Databases', 'Lab 1'),
    ClassSlot('Wednesday', '14:00 – 16:00', 'BIT 4108 — Software Eng.', 'Google Meet', isOnline: true),
    ClassSlot('Thursday', '08:00 – 10:00', 'BIT 4109 — Systems Analysis', 'Room 8'),
    ClassSlot('Friday', '10:00 – 12:00', 'BIT 4107 — Mobile App Dev (Lab)', 'Lab 3'),
  ];

  /// Returns the next upcoming class following the order classes appear
  /// in [slots], looping back to Monday's first class if today is past
  /// the last one in the week. This is a simplified "next class" lookup
  /// suitable for a demo dashboard — it orders by weekday only, not by
  /// the actual current time of day.
  static ClassSlot nextClass(DateTime now) {
    const weekdayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayIndex = now.weekday - 1; // DateTime.monday == 1

    for (int offset = 0; offset < 7; offset++) {
      final dayName = weekdayOrder[(todayIndex + offset) % 7];
      final matches = slots.where((s) => s.day == dayName).toList();
      if (matches.isNotEmpty) {
        return matches.first;
      }
    }
    return slots.first;
  }

  static List<ClassSlot> get onlineSlots => slots.where((s) => s.isOnline).toList();
}
