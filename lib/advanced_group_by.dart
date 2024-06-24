import 'dart:collection';
import 'package:collection/collection.dart';
import 'db.dart';
import 'models.dart';
import 'package:table_calendar/table_calendar.dart' as cal;

LinkedHashMap<DateTime, Map<Category, Duration>> groupTimelogCategoriesByDayAndSumDurations() {
  final list = timelogSelectAll();
  var map1 = _step1(list);
  return _step2(map1);
}

LinkedHashMap<DateTime, List<CategoryDuration>> _step1(List<TimelogWithCategories> list) {
  var map = LinkedHashMap<DateTime, List<CategoryDuration>>(
      equals: cal.isSameDay,
      hashCode: getDateTimeHashCode,
      isValidKey: (key) => key != null);

  for (final tc in list) {
    if (map.containsKey(tc.timelog!.startTime!)) {
      map[tc.timelog!.startTime!]!.add(_add1(tc));
    } else {
      map[tc.timelog!.startTime!] =
      List<CategoryDuration>.empty(growable: true);
      map[tc.timelog!.startTime!]!.add(_add1(tc));
    }
  }

  return map;
}

CategoryDuration _add1(TimelogWithCategories tc) {
  return CategoryDuration()
    ..category = tc.category
    ..duration = tc.timelog!.endTime!.difference(tc.timelog!.startTime!);
}

LinkedHashMap<DateTime, Map<Category, Duration>> _step2(LinkedHashMap<DateTime, List<CategoryDuration>> map1) {
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

  return map2;
}
