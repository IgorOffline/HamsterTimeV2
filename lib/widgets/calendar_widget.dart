import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:table_calendar/table_calendar.dart' as cal;
import '../models.dart';

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
