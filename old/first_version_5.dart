import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
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
          scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: WidgetStateProperty.all<bool>(true))),
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
  List<String>.generate(30, (i) => '$i. LOREM IPSUM');

  void _incrementCounter() {
    setState(() {
      if (_counter == 999) {
        debugPrint('Using sqlite3 ${sql.sqlite3.version}');
        final db = sql.sqlite3
            .open('C:\\C3\\dev\\flutter\\sqlite\\hamstertimev2.sqlite3');

        final sql.ResultSet resultSet =
        db.select('SELECT c.id_category id, c.name FROM category c');

        for (final sql.Row row in resultSet) {
          debugPrint('Category[id: ${row['id']}, name: ${row['name']}]');
        }

        db.dispose();
      }

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
        body: Column(children: [
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
                    child: ListView.builder(
                        itemCount: _loremIpsums.length,
                        prototypeItem:
                        ListTile(title: Text(_loremIpsums.first)),
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(_loremIpsums[index]));
                        }))),
          ]),
          ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: MediaQuery.of(context).size.height - 500),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('LOREM IPSUM 123'),
                  FloatingActionButton(
                    heroTag: 'Insert timelog',
                    onPressed: () async {
                      final retVal = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SecondRoute(secondCounterInit: _counter)));
                      setState(() {
                        _counter = retVal;
                      });
                    },
                    tooltip: 'Insert timelog',
                    child: const Text('Insert timelog'),
                  ),
                  FloatingActionButton(
                    heroTag: 'Increment',
                    onPressed: _incrementCounter,
                    tooltip: 'Increment',
                    child: Text('$_counter'),
                  ),
                ],
              ))
        ]));
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

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key, required this.secondCounterInit});

  final int secondCounterInit;

  @override
  State<SecondRoute> createState() => _SecondStatefulWidgetState();
}

class _SecondStatefulWidgetState extends State<SecondRoute> {
  late int secondCounter;

  @override
  void initState() {
    secondCounter = widget.secondCounterInit;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Second Route'),
        ),
        body: Center(
          child: Row(children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, secondCounter);
                },
                child: const Text('Go back')),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    ++secondCounter;
                  });
                },
                child: Text('$secondCounter'))
          ]),
        ));
  }
}
