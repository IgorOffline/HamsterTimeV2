import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  final List<String> loremIpsums =
  List<String>.generate(30, (i) => 'LOREM IPSUM $i');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          const Text('IPSUM123'),
          Container(),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 240),
              child: const TableBasicsExample()),
          Container(
              color: Theme.of(context).colorScheme.inversePrimary,
              child: ListView.builder(
                  itemCount: loremIpsums.length,
                  prototypeItem: ListTile(title: Text(loremIpsums.first)),
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(loremIpsums[index]));
                  })),
        ],
      ),
    );
  }

  List<Widget> _children() => List<Widget>.generate(loremIpsums.length, (i) {
    return Text(loremIpsums[i].toString());
  });
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
