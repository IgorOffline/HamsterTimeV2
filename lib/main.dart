import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:table_calendar/table_calendar.dart' as cal;
import 'package:intl/intl.dart' as intl;

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
  DateTime? selectedDay;

  final today = DateTime.now();
  DateTime? firstDay;
  DateTime? lastDay;
}

String _formatDateTime(DateTime dt) {
  return intl.DateFormat('yyyy-MM-dd').format(dt);
}

int _getDateTimeHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
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
                child: TextButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SecondRoute()));
                    },
                    child: provider.Consumer<Globalz>(
                      builder: (context, global, child) => Text(
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

class SecondRoute extends StatelessWidget {
  const SecondRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            provider.Consumer<Globalz>(
              builder: (context, global, child) => Text(
                '${global.value}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
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
