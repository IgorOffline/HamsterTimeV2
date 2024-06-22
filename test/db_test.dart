import 'package:flutter_test/flutter_test.dart';
import 'package:hamster_time_v2/main.dart';

void main() {
  //test3();
}

void test1() {
  testWidgets('More than 3 categories', (WidgetTester tester) async {
    final categories = dbCategorySelectAll();
    expect(categories.length > 3, true);
  });
}

void test2() {
  testWidgets('Insert successful', (WidgetTester tester) async {
    final timelog = Timelog();
    timelog.note = '<TEST>';
    timelog.time = DateTime.now();
    timelog.category = 1;
    final insert = dbTimelogInsert(timelog);
    expect(insert, true);
  });
}

void test3() {
  testWidgets('Timelog select all', (WidgetTester tester) async {
    final timelogs = dbTimelogSelectAll();
    expect(timelogs.isNotEmpty, true);
  });
}