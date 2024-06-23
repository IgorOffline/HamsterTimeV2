import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'db.dart';
import 'models.dart';
import 'colors.dart' as colorz;

class TimelogRoute extends StatefulWidget {
  const TimelogRoute(
      {super.key, required this.selectedDay, required this.timelog});

  final DateTime selectedDay;
  final Timelog timelog;

  @override
  State<StatefulWidget> createState() => _TimelogRouteState();
}

class _TimelogRouteState extends State<TimelogRoute> {
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
      startTimeController.text =
          formatDateTimeForInputEmpty(widget.selectedDay);
      endTimeController.text = formatDateTimeForInputEmpty(widget.selectedDay);
    } else {
      startTimeController.text =
          formatDateTimeForInput(widget.timelog.startTime!);
      endTimeController.text = formatDateTimeForInput(widget.timelog.endTime!);
      noteController.text = widget.timelog.note!;
      if (widget.timelog.category != null) {
        final category =
            categories.firstWhereOrNull((e) => e.id == widget.timelog.category);
        if (category != null) {
          categoryController.text = category.name!;
          categoryId = category.id;
        }
      }
      if (widget.timelog.subcategory != null) {
        final subcategory = categories
            .firstWhereOrNull((e) => e.id == widget.timelog.subcategory);
        if (subcategory != null) {
          subcategoryController.text = subcategory.name!;
          subcategoryId = subcategory.id;
        }
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
        foregroundColor: colorz.kTextIcons,
        backgroundColor: colorz.kDarkPrimaryColor,
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
                        timelog.id = widget.timelog.id;
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
