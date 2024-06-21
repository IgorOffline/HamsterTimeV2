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
}

class Category {
  int? id;
  String? name;

  @override
  String toString() => 'Timelog= [id= $id, name= $name]';
}

class Timelog {
  int? id;
  int? category;
  int? subcategory;
  DateTime? time;
  String? note;
  DateTime? ctime;
  DateTime? mtime;

  @override
  String toString() => 'Timelog= [id= $id, note= $note]';
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

String _formatDateTimeToString(DateTime dt) {
  return intl.DateFormat('yyyy-MM-dd').format(dt);
}

DateTime _formatStringToDateTime(String s) {
  return DateTime.parse(s);
}

String _formatDateTimeForInput(DateTime dt) {
  return '${_formatDateTimeToString(dt)} 00:00';
}

int _getDateTimeHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

String _dbUrl() {
  return 'C:\\C3\\dev\\flutter\\sqlite\\hamstertimev2.sqlite3';
}

List<Category> dbSelectCategories() {
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Column(
        children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300, maxHeight: 500),
              child: const TableBasicsExample()),
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
                                    builder: (context) => SecondRoute(
                                        time: global.calUtils.selectedDay!)));
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

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key, required this.time});

  final DateTime time;

  @override
  State<StatefulWidget> createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {
  final categories = dbSelectCategories();
  final timeController = TextEditingController();
  final noteController = TextEditingController();
  final categoryController = TextEditingController();
  final subcategoryController = TextEditingController();
  int? categoryId = -1;
  int? subcategoryId = -1;

  @override
  void initState() {
    super.initState();
    timeController.text = _formatDateTimeForInput(widget.time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Second Route'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(
                        border: UnderlineInputBorder(), labelText: 'Time')),
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
                      timelog.time =
                          _formatStringToDateTime(timeController.text);
                      timelog.note = noteController.text;
                      timelog.category = categoryId;
                      timelog.subcategory = subcategoryId;
                      debugPrint('$timelog');
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
