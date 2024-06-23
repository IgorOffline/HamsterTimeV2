import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:table_calendar/table_calendar.dart' as cal;
import 'package:intl/intl.dart' as intl;
import 'package:sqlite3/sqlite3.dart' as sql;

void main() {
  runApp(
    provider.ChangeNotifierProvider(
      create: (context) => Globalz(),
      child: const MyApp(),
    ),
  );
}

class Globalz with ChangeNotifier {
  int value = 0;

  CalUtils calUtils = CalUtils();

  var timeTimelogs = LinkedHashMap<DateTime, List<Timelog>>(
      equals: cal.isSameDay,
      hashCode: getDateTimeHashCode,
      isValidKey: (key) => key != null);

  void initGlobal() {
    timeTimelogs.clear();
    final list = dbTimelogSelectAll();
    for (final map in list) {
      final t = map['timelog'] as Timelog;
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

  int timeTimelogsLength() {
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
}

class Category {
  int? id;
  String? name;

  @override
  String toString() => 'Category= [id=$id, name=$name]';
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

String _formatDateTimeToDateString(DateTime dt) {
  return intl.DateFormat('yyyy-MM-dd').format(dt);
}

String _formatDateTimeToTimeString(DateTime dt) {
  return intl.DateFormat().add_Hm().format(dt);
}

DateTime formatStringToDateTime(String s) {
  return DateTime.parse(s);
}

String _formatDateTimeForInput(DateTime dt) {
  return '${_formatDateTimeToDateString(dt)} 00:00';
}

int getDateTimeHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

String _dbUrl() {
  return 'C:\\C3\\dev\\flutter\\sqlite\\hamstertimev2.sqlite3';
}

List<Category> dbCategorySelectAll() {
  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_dbUrl());

  final sql.ResultSet resultSet =
      db.select('SELECT c.id_category id, c.name FROM category c');

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

List<Map<String, dynamic>> dbTimelogSelectAll() {
  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_dbUrl());

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

  final timelogs = List<Map<String, dynamic>>.empty(growable: true);

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
    c.name = row['category_name'];
    final s = Category();
    s.name = row['subcategory_name'];

    timelogs.add({
      'timelog': t,
      'category': c,
      'subcategory': s,
    });
  }

  return timelogs;
}

bool dbTimelogInsert(Timelog timelog) {
  final now = DateTime.now();
  timelog.ctime = now;
  timelog.mtime = now;

  debugPrint('Using sqlite3 ${sql.sqlite3.version}');
  final db = sql.sqlite3.open(_dbUrl());

  final stmt = db.prepare(
      'INSERT INTO timelog (note, start_time, end_time, category_id, subcategory_id, ctime, mtime) VALUES (?, ?, ?, ?, ?, ?, ?)');
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

bool dbTimelogUpdate(Timelog timelog) {
  final now = DateTime.now();
  timelog.mtime = now;

  //

  return true;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: WidgetStateProperty.all<bool>(true))),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var global = context.read<Globalz>();
      global.initGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Column(
        children: [
          Row(children: [
            ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 300, maxHeight: 500),
                child: const TableBasicsExample()),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 320,
                  maxHeight: 400),
              child: Container(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: provider.Consumer<Globalz>(
                      builder: (context, global, child) => ListView.builder(
                          itemCount: global.timeTimelogsLength(),
                          prototypeItem:
                              const ListTile(title: Text('Prototype')),
                          itemBuilder: (context, index) {
                            return ListTile(
                                title: Row(
                              children: [
                                Flexible(
                                    child: Text(
                                        global.getTimeTimelogNote(index),
                                        overflow: TextOverflow.ellipsis, maxLines: 2,)),
                                TextButton(
                                  child: const Icon(Icons.edit),
                                  onPressed: () {
                                    debugPrint('$index');
                                  },
                                )
                              ],
                            ));
                          }))),
            ),
          ]),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 320,
                maxHeight: 400),
            child: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
                child: provider.Consumer<Globalz>(
                    builder: (context, global, child) => TextButton(
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TimelogInsertUpdateRoute(
                                            selectedDay:
                                                global.calUtils.selectedDay!,
                                            timelog: Timelog())));
                          },
                          child: Text(
                            'SecondRoute (${global.value})',
                          ),
                        ))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var global = context.read<Globalz>();
          global.increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TableBasicsExample extends StatelessWidget {
  const TableBasicsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('TableCalendar'),
        ),
        body: provider.Consumer<Globalz>(
          builder: (context, global, child) => cal.TableCalendar(
            firstDay: global.calUtils.firstDay!,
            lastDay: global.calUtils.lastDay!,
            focusedDay: global.calUtils.focusedDay,
            calendarFormat: global.calUtils.calendarFormat,
            selectedDayPredicate: (day) {
              return cal.isSameDay(global.calUtils.selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!cal.isSameDay(global.calUtils.selectedDay, selectedDay)) {
                var global = context.read<Globalz>();
                global.setSelectedDay(selectedDay);
                global.setFocusedDay(focusedDay);
              }
            },
            onFormatChanged: (format) {
              if (global.calUtils.calendarFormat != format) {
                var global = context.read<Globalz>();
                global.setCalendarFormat(format);
              }
            },
            onPageChanged: (focusedDay) {
              global.calUtils.focusedDay = focusedDay;
            },
          ),
        ));
  }
}

class TimelogInsertUpdateRoute extends StatefulWidget {
  const TimelogInsertUpdateRoute(
      {super.key, required this.selectedDay, required this.timelog});

  final DateTime selectedDay;
  final Timelog timelog;

  @override
  State<StatefulWidget> createState() => _TimelogInsertUpdateRouteState();
}

class _TimelogInsertUpdateRouteState extends State<TimelogInsertUpdateRoute> {
  final categories = dbCategorySelectAll();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController();
  final subcategoryController = TextEditingController();
  int? categoryId;
  int? subcategoryId;

  @override
  void initState() {
    super.initState();
    debugPrint('${widget.timelog}');
    if (widget.timelog.id == null) {
      startTimeController.text = _formatDateTimeForInput(widget.selectedDay);
      endTimeController.text = _formatDateTimeForInput(widget.selectedDay);
    } else {
      startTimeController.text =
          _formatDateTimeForInput(widget.timelog.startTime!);
      endTimeController.text = _formatDateTimeForInput(widget.timelog.endTime!);
      noteController.text = widget.timelog.note!;
      if (widget.timelog.category != null) {
        categories.firstWhere((e) => e.id == widget.timelog.category);
      }
      if (widget.timelog.subcategory != null) {
        categories.firstWhere((e) => e.id == widget.timelog.subcategory);
      }
    }
  }

  String getTitle() {
    return widget.timelog.id == null ? 'New Timelog' : 'Edit Timelog';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(getTitle()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                TextFormField(
                    controller: startTimeController,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Start time')),
                TextFormField(
                    controller: endTimeController,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(), labelText: 'End time')),
                TextFormField(
                    controller: noteController,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(), labelText: 'Note')),
                DropdownMenu(
                    controller: categoryController,
                    label: const Text('Category'),
                    dropdownMenuEntries: categories
                        .map<DropdownMenuEntry<Category>>((Category c) {
                      return DropdownMenuEntry<Category>(
                          value: c, label: c.name!);
                    }).toList(),
                    onSelected: (Category? c) => categoryId = c?.id),
                DropdownMenu(
                    controller: subcategoryController,
                    label: const Text('Subcategory'),
                    dropdownMenuEntries: categories
                        .map<DropdownMenuEntry<Category>>((Category c) {
                      return DropdownMenuEntry<Category>(
                          value: c, label: c.name!);
                    }).toList(),
                    onSelected: (Category? c) => subcategoryId = c?.id),
                TextButton(
                    onPressed: () {
                      var timelog = Timelog();
                      timelog.startTime =
                          formatStringToDateTime(startTimeController.text);
                      timelog.endTime =
                          formatStringToDateTime(endTimeController.text);
                      timelog.note = noteController.text;
                      timelog.category = categoryId;
                      timelog.subcategory = subcategoryId;
                      debugPrint('$timelog');
                      if (widget.timelog.id == null) {
                        dbTimelogInsert(timelog);
                      } else {
                        dbTimelogUpdate(timelog);
                      }
                      var global = context.read<Globalz>();
                      global.initGlobal();
                      Navigator.pop(context);
                    },
                    child: const Text('SAVE')),
                const Text('You have pushed the button this many times:'),
                provider.Consumer<Globalz>(
                  builder: (context, global, child) => Text(
                    '${global.value}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var global = context.read<Globalz>();
          global.increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
