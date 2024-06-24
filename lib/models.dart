import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' as cal;
import 'package:intl/intl.dart' as intl;
import 'db.dart' as db;

class Globalz with ChangeNotifier {
  int value = 0;

  CalUtils calUtils = CalUtils();

  var timeTimelogs = LinkedHashMap<DateTime, List<Timelog>>(
      equals: cal.isSameDay,
      hashCode: getDateTimeHashCode,
      isValidKey: (key) => key != null);

  void initGlobal() {
    timeTimelogs.clear();
    final list = db.timelogSelectAll();
    for (final tc in list) {
      final t = tc.timelog!;
      if (timeTimelogs.containsKey(t.startTime)) {
        timeTimelogs[t.startTime]!.add(t);
      } else {
        timeTimelogs[t.startTime!] = List<Timelog>.empty(growable: true);
        timeTimelogs[t.startTime]!.add(t);
      }
    }
    notifyListeners();
  }

  void increment() {
    value += 1;
    notifyListeners();
  }

  void setCalendarFormat(cal.CalendarFormat calendarFormat) {
    calUtils.calendarFormat = calendarFormat;
    notifyListeners();
  }

  void setFocusedDay(DateTime focusedDay) {
    calUtils.focusedDay = focusedDay;
    notifyListeners();
  }

  void setSelectedDay(DateTime selectedDay) {
    calUtils.selectedDay = selectedDay;
    notifyListeners();
  }

  int getTimeTimelogsLength() {
    if (timeTimelogs[calUtils.selectedDay!] == null) {
      return 0;
    } else {
      return timeTimelogs[calUtils.selectedDay!]!.length;
    }
  }

  String getTimeTimelogNote(int index) {
    if (timeTimelogs[calUtils.selectedDay!] == null) {
      return '';
    }
    final t = timeTimelogs[calUtils.selectedDay!]!.elementAt(index);
    final startTimeStr =
        t.startTime == null ? '' : _formatDateTimeToTimeString(t.startTime!);
    final endTimeStr =
        t.endTime == null ? '' : _formatDateTimeToTimeString(t.endTime!);
    return t.note == null
        ? ''
        : '${index + 1}. ($startTimeStr-$endTimeStr) ${t.note}';
  }

  Timelog getTimelog(int index) {
    return timeTimelogs[calUtils.selectedDay!]!.elementAt(index);
  }
}

class Category {
  int? id;
  String? name;

  @override
  String toString() => 'Category= [id=$id, name=$name]';

  @override
  operator ==(other) =>
      other is Category && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

class Timelog {
  int? id;
  int? category;
  int? subcategory;
  DateTime? startTime;
  DateTime? endTime;
  String? note;
  DateTime? ctime;
  DateTime? mtime;

  @override
  String toString() => 'Timelog= [id=$id, note=$note, startTime=$startTime]';
}

class CalUtils {
  CalUtils() {
    firstDay = DateTime(today.year, today.month - 12, today.day);
    lastDay = DateTime(today.year, today.month + 12, today.day);
  }

  cal.CalendarFormat calendarFormat = cal.CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay = DateTime.now();

  final today = DateTime.now();
  DateTime? firstDay;
  DateTime? lastDay;
}

class TimelogWithCategories {
  Timelog? timelog;
  Category? category;
  Category? subcategory;

  @override
  String toString() =>
      'TimelogWithCategories= [timelog=$timelog, category=$category, subcategory=$subcategory]';
}

class CategoryDuration {
  Category? category;
  Duration? duration;

  @override
  String toString() =>
      'CategoryDuration= [category=$category, duration=$duration]';
}

String _formatDateTimeToDateString(DateTime dt) {
  return intl.DateFormat('yyyy-MM-dd').format(dt);
}

String _formatDateTimeToTimeString(DateTime dt) {
  return intl.DateFormat().add_Hm().format(dt);
}

DateTime formatStringToDateTime(String s) {
  return DateTime.parse(s);
}

String formatDateTimeForInputEmpty(DateTime dt) {
  return '${_formatDateTimeToDateString(dt)} 00:00';
}

String formatDateTimeForInput(DateTime dt) {
  return intl.DateFormat('yyyy-MM-dd').add_Hm().format(dt);
}

int getDateTimeHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
