import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
as grid;
import 'package:table_calendar/table_calendar.dart' as cal;

import 'utils.dart' as calutil;

void main() {
  runApp(const MyApp());
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
      ),
      home: const MyHomePage(title: 'Hamster Time V2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final List<String> _loremIpsums =
  List<String>.generate(30, (i) => 'LOREM IPSUM $i');

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: grid.StaggeredGrid.count(crossAxisCount: 12, children: [
        const grid.StaggeredGridTile.count(
          crossAxisCellCount: 6,
          mainAxisCellCount: 9,
          child: TableBasicsExample(),
        ),
        grid.StaggeredGridTile.count(
          crossAxisCellCount: 6,
          mainAxisCellCount: 9,
          child: Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              child: ListView.builder(
                  itemCount: _loremIpsums.length,
                  prototypeItem: ListTile(title: Text(_loremIpsums.first)),
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(_loremIpsums[index]));
                  })),
        ),
        grid.StaggeredGridTile.count(
            crossAxisCellCount: 6,
            mainAxisCellCount: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100, maxWidth: 100),
              child: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: Text('3 $_counter'),
              ),
            )),
        grid.StaggeredGridTile.count(
            crossAxisCellCount: 6,
            mainAxisCellCount: 3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100, maxWidth: 100),
              child: FloatingActionButton(
                onPressed: _incrementCounter,
                tooltip: 'Increment',
                child: Text('4 $_counter'),
              ),
            )),
      ]),
    );
  }
}

class TableBasicsExample extends StatefulWidget {
  const TableBasicsExample({super.key});

  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  cal.CalendarFormat _calendarFormat = cal.CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TableCalendar'),
      ),
      body: cal.TableCalendar(
        firstDay: calutil.kFirstDay,
        lastDay: calutil.kLastDay,
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return cal.isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!cal.isSameDay(_selectedDay, selectedDay)) {
            // Call `setState()` when updating the selected day
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            final targetDay = DateTime.parse('2024-06-19');
            if (cal.isSameDay(selectedDay, targetDay)) {
              //debugPrint('selectedDay= $selectedDay, event= ${calutil.kEvents[selectedDay]?.first}');
              //calutil.kEvents.forEach((k, v) => debugPrint('event= $k $v'));
            }
            calutil.kEvents[selectedDay]?.forEach((event) {
              debugPrint('event= $event ($selectedDay)');
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            // Call `setState()` when updating calendar format
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          // No need to call `setState()` here
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
