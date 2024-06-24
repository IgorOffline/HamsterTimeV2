import 'package:flutter/material.dart';
import 'package:hamster_time_v2/timelog_route.dart';
import 'package:provider/provider.dart' as provider;
import 'package:table_calendar/table_calendar.dart' as cal;
import 'colors.dart' as colorz;
import 'models.dart';

void main() {
  runApp(
    provider.ChangeNotifierProvider(
      create: (context) => Globalz(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hamster Time V2',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
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
      _initGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorz.kTextIcons,
        backgroundColor: colorz.kDarkPrimaryColor,
        title: const Text('Hamster Time V2'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 300, maxHeight: 500),
                      child: const TableBasicsExample())),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 332,
                      maxHeight: MediaQuery.of(context).size.height - 170),
                  child: Container(
                      decoration: const BoxDecoration(
                          border:
                              Border(bottom: BorderSide(), left: BorderSide())),
                      child: provider.Consumer<Globalz>(
                          builder: (context, global, child) =>
                              _listView(global))),
                ),
              ),
            ]),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: provider.Consumer<Globalz>(
                      builder: (context, global, child) => TextButton(
                            onPressed: () async {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => TimelogRoute(
                                              selectedDay:
                                                  global.calUtils.selectedDay!,
                                              timelog: Timelog())))
                                  .whenComplete(() {
                                _initGlobal();
                              });
                            },
                            child: Text(
                              'New Timelog (${global.value})',
                            ),
                          ))),
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

  ListView _listView(Globalz global) {
    return ListView.builder(
        itemCount: global.getTimeTimelogsLength(),
        prototypeItem: const ListTile(title: Text('Prototype')),
        itemBuilder: (context, index) {
          return ListTile(
              title: Row(
            children: [
              Flexible(
                  child: Text(
                global.getTimeTimelogNote(index),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )),
              TextButton(
                child: const Icon(Icons.edit),
                onPressed: () async {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TimelogRoute(
                                  selectedDay: global.calUtils.selectedDay!,
                                  timelog: global.getTimelog(index))))
                      .whenComplete(() {
                    _initGlobal();
                  });
                },
              )
            ],
          ));
        });
  }

  void _initGlobal() {
    debugPrint('_initGlobal()');
    var global = context.read<Globalz>();
    global.initGlobal();
  }
}

class TableBasicsExample extends StatelessWidget {
  const TableBasicsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
