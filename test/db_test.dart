import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_time_v2/db.dart';
import 'package:hamster_time_v2/models.dart';
import 'package:table_calendar/table_calendar.dart' as cal;

void main() {
  test5();
}

void test1() {
  testWidgets('More than 3 categories', (WidgetTester tester) async {
    final categories = categorySelectAll();
    expect(categories.length > 3, true);
  });
}

void test2() {
  testWidgets('Insert successful', (WidgetTester tester) async {
    final timelog = Timelog();
    timelog.note = '<TEST>';
    timelog.startTime = DateTime.now();
    timelog.category = 1;
    final insert = timelogInsert(timelog);
    expect(insert, true);
  });
}

void test3() {
  testWidgets('Timelog select all', (WidgetTester tester) async {
    final timelogs = timelogSelectAll();
    expect(timelogs.isNotEmpty, true);
  });
}

void test4() {
  testWidgets('Timelogs split by time', (WidgetTester tester) async {
    final t1 = Timelog()
      ..startTime = formatStringToDateTime('2024-06-21 01:00');
    final t2 = Timelog()
      ..startTime = formatStringToDateTime('2024-06-21 02:00');
    final t3 = Timelog()
      ..startTime = formatStringToDateTime('2024-06-22 03:00');
    final t4 = Timelog()
      ..startTime = formatStringToDateTime('2024-06-22 04:00');
    final list = List<Timelog>.empty(growable: true);
    list.add(t1);
    list.add(t2);
    list.add(t3);
    list.add(t4);
    var map = LinkedHashMap<DateTime, List<Timelog>>(
        equals: cal.isSameDay,
        hashCode: getDateTimeHashCode,
        isValidKey: (key) => key != null);
    for (final t in list) {
      if (map.containsKey(t.startTime)) {
        map[t.startTime]!.add(t);
      } else {
        map[t.startTime!] = List<Timelog>.empty(growable: true);
        map[t.startTime]!.add(t);
      }
    }
    expect(map.isNotEmpty, true);
  });
}

void test5() {
  testWidgets('Group timelogs', (WidgetTester tester) async {
    var map1 = step1();

    var map2 = LinkedHashMap<DateTime, Map<Category, Duration>>(
        equals: cal.isSameDay,
        hashCode: getDateTimeHashCode,
        isValidKey: (key) => key != null);

    for (final key1 in map1.keys) {
      final grouped = map1[key1]!.groupListsBy((e) => e.category!);
      final categoryDuration = <Category, Duration>{};
      for (final key2 in grouped.keys) {
        var sum = const Duration();
        for (final value2 in grouped[key2]!) {
          sum += value2.duration!;
        }
        categoryDuration[key2] = sum;
      }
      map2[key1] = categoryDuration;
    }

    expect(map2.isNotEmpty, true);
  });
}

LinkedHashMap<DateTime, List<CategoryDuration>> step1() {
  var map = LinkedHashMap<DateTime, List<CategoryDuration>>(
      equals: cal.isSameDay,
      hashCode: getDateTimeHashCode,
      isValidKey: (key) => key != null);

  final list = timelogSelectAll();
  for (final tc in list) {
    if (map.containsKey(tc.timelog!.startTime!)) {
      map[tc.timelog!.startTime!]!.add(add1(tc));
    } else {
      map[tc.timelog!.startTime!] =
          List<CategoryDuration>.empty(growable: true);
      map[tc.timelog!.startTime!]!.add(add1(tc));
    }
  }

  return map;
}

CategoryDuration add1(TimelogWithCategories tc) {
  return CategoryDuration()
    ..category = tc.category
    ..duration = tc.timelog!.endTime!.difference(tc.timelog!.startTime!);
}
