String normalizeTime(String value) {
  final raw = value.trim();
  if (raw.isEmpty) {
    return '00:00';
  }

  final hhmm = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
  if (hhmm != null) {
    return _format24(
      _safeHour(int.tryParse(hhmm.group(1) ?? '') ?? 0),
      _safeMinute(int.tryParse(hhmm.group(2) ?? '') ?? 0),
    );
  }

  final hhmmss = RegExp(r'^(\d{1,2}):(\d{2}):(\d{2})$').firstMatch(raw);
  if (hhmmss != null) {
    return _format24(
      _safeHour(int.tryParse(hhmmss.group(1) ?? '') ?? 0),
      _safeMinute(int.tryParse(hhmmss.group(2) ?? '') ?? 0),
    );
  }

  final amPm = RegExp(r'^(\d{1,2}):(\d{2})\s*([AaPp][Mm])$').firstMatch(raw);
  if (amPm != null) {
    var hour = int.tryParse(amPm.group(1) ?? '') ?? 0;
    final minute = _safeMinute(int.tryParse(amPm.group(2) ?? '') ?? 0);
    final meridiem = (amPm.group(3) ?? '').toUpperCase();

    hour = hour % 12;
    if (meridiem == 'PM') {
      hour += 12;
    }

    return _format24(hour, minute);
  }

  final parsedDate = DateTime.tryParse(raw);
  if (parsedDate != null) {
    final local = parsedDate.toLocal();
    return _format24(local.hour, local.minute);
  }

  return '00:00';
}

String formatTime24To12(String time24) {
  final normalized = normalizeTime(time24);
  final parts = normalized.split(':');
  if (parts.length != 2) {
    return normalized;
  }

  final hour24 = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  final isPm = hour24 >= 12;
  final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);

  return '$hour12:${_pad2(minute)} ${isPm ? 'PM' : 'AM'}';
}

int toMinutes(String time) {
  final normalized = normalizeTime(time);
  final parts = normalized.split(':');
  if (parts.length != 2) {
    return 0;
  }

  final hours = int.tryParse(parts[0]) ?? 0;
  final minutes = int.tryParse(parts[1]) ?? 0;

  return (_safeHour(hours) * 60) + _safeMinute(minutes);
}

String toISODate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${_pad2(date.month)}-${_pad2(date.day)}';
}

DateTime startOfWeek(DateTime date) {
  final dayOnly = DateTime(date.year, date.month, date.day);
  final offset = dayOnly.weekday % 7;
  return dayOnly.subtract(Duration(days: offset));
}

DateTime endOfWeek(DateTime date) {
  return startOfWeek(date).add(const Duration(days: 6));
}

DateTime startOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime endOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0);
}

List<String> monthWeekStartDates(DateTime referenceDate) {
  final monthStart = startOfMonth(referenceDate);
  final monthEnd = endOfMonth(referenceDate);
  final gridStart = startOfWeek(monthStart);
  final gridEnd = endOfWeek(monthEnd);

  final output = <String>[];
  var cursor = gridStart;

  while (!cursor.isAfter(gridEnd)) {
    output.add(toISODate(cursor));
    cursor = cursor.add(const Duration(days: 7));
  }

  return output;
}

String _format24(int hour, int minute) {
  return '${_pad2(_safeHour(hour))}:${_pad2(_safeMinute(minute))}';
}

String _pad2(int value) => value.toString().padLeft(2, '0');

int _safeHour(int value) {
  if (value < 0) {
    return 0;
  }
  if (value > 23) {
    return 23;
  }
  return value;
}

int _safeMinute(int value) {
  if (value < 0) {
    return 0;
  }
  if (value > 59) {
    return 59;
  }
  return value;
}
