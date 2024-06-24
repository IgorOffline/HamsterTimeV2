import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hamster_time_v2/models.dart';
import '../colors.dart' as colorz;

class GraphWidget extends StatefulWidget {
  const GraphWidget({super.key, required this.global});

  final Globalz global;

  @override
  State<StatefulWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  var titlesMap = <int, String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: BarChart(_data()));
  }

  BarChartData _data() {
    final barGroupsList = List<BarChartGroupData>.empty(growable: true);
    if (widget.global.dayCategoryDuration
        .containsKey(widget.global.calUtils.selectedDay)) {
      final map = widget
          .global.dayCategoryDuration[widget.global.calUtils.selectedDay!]!;
      var index = 0;
      map.forEach((k, v) {
        barGroupsList.add(
            _makeGroupData(index, v.inMinutes > 0 ? v.inMinutes / 60.0 : 0));
        titlesMap[index] = k.name!;
        index++;
      });
    }
    return BarChartData(
        barGroups: barGroupsList, titlesData: _makeTitlesData());
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
            toY: 24,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  FlTitlesData _makeTitlesData() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: _getTitles,
          reservedSize: 38,
        ),
      ),
    );
  }

  Widget _getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: colorz.kPrimaryText,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text = Text(titlesMap[value.toInt()] ?? '', style: style);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }
}
