import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hamster_time_v2/models.dart';

class GraphWidget extends StatelessWidget {
  const GraphWidget({super.key, required this.global});

  final Globalz global;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BarChart(_data()));
  }

  BarChartData _data() {
    final list = List<BarChartGroupData>.empty(growable: true);
    if (global.dayCategoryDuration.containsKey(global.calUtils.selectedDay)) {
      final map = global.dayCategoryDuration[global.calUtils.selectedDay!]!;
      map.forEach((k, v) {
        list.add(_makeGroupData(0, v.inMinutes.toDouble()));
      });
    }
    return BarChartData(barGroups: list);
  }

  BarChartGroupData _makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          width: width,
          borderSide: isTouched
              ? const BorderSide()
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 24 * 60,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
