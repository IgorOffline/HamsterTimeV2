import 'package:flutter/material.dart' show debugPrint;
import 'models.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

String _url() {
  return 'C:\\C3\\dev\\flutter\\sqlite\\hamstertimev2.sqlite3';
}

List<Category> categorySelectAll() {
  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_url());

  final sql.ResultSet resultSet =
      db.select('select c.id_category id, c.name from category c');

  final categories = List<Category>.empty(growable: true);

  for (final sql.Row row in resultSet) {
    final c = Category();
    c.id = row['id'];
    c.name = row['name'];

    categories.add(c);
  }

  db.dispose();

  debugPrint('categories.length= ${categories.length}');

  return categories;
}

List<TimelogWithCategories> timelogSelectAll() {
  final timelogs = List<TimelogWithCategories>.empty(growable: true);

  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_url());

  final sql.ResultSet resultSet = db.select("""
  select 
  t.id_timelog id,
  t.category_id,
  c.name 'category_name',
  t.subcategory_id,
  s.name 'subcategory_name',
  t.start_time,
  t.end_time,
  t.note,
  t.ctime,
  t.mtime
  from timelog t
  left join category c on t.category_id == c.id_category
  left join category s on t.subcategory_id == s.id_category;
  """);

  for (final sql.Row row in resultSet) {
    final t = Timelog();
    t.id = row['id'];
    t.category = row['category_id'];
    t.subcategory = row['subcategory_id'];
    t.startTime = formatStringToDateTime(row['start_time']);
    t.endTime = formatStringToDateTime(row['end_time']);
    t.note = row['note'];
    t.ctime = formatStringToDateTime(row['ctime']);
    t.mtime = formatStringToDateTime(row['mtime']);
    final c = Category();
    c.id = t.category;
    c.name = row['category_name'];
    final s = Category();
    s.id = t.subcategory;
    s.name = row['subcategory_name'];

    timelogs.add(TimelogWithCategories()
      ..timelog = t
      ..category = c
      ..subcategory = s);
  }

  return timelogs;
}

bool timelogInsert(Timelog timelog) {
  final now = DateTime.now();
  timelog.ctime = now;
  timelog.mtime = now;

  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_url());

  final stmt = db.prepare(
      'insert into timelog (note, start_time, end_time, category_id, subcategory_id, ctime, mtime) values (?, ?, ?, ?, ?, ?, ?)');
  stmt.execute([
    timelog.note,
    timelog.startTime.toString(),
    timelog.endTime.toString(),
    timelog.category,
    timelog.subcategory,
    timelog.ctime.toString(),
    timelog.mtime.toString()
  ]);

  db.dispose();

  return true;
}

bool timelogUpdate(Timelog timelog) {
  final now = DateTime.now();
  timelog.mtime = now;

  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_url());

  final stmt = db.prepare(
      'update timelog SET note=?, category_id=?, subcategory_id=?, start_time=?, end_time=?, mtime=? where id_timelog=?');
  stmt.execute([
    timelog.note,
    timelog.category,
    timelog.subcategory,
    timelog.startTime.toString(),
    timelog.endTime.toString(),
    timelog.mtime.toString(),
    timelog.id
  ]);

  db.dispose();

  return true;
}
