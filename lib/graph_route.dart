import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'colors.dart' as colorz;

class GraphRoute extends StatelessWidget {
  const GraphRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: colorz.kTextIcons,
          backgroundColor: colorz.kDarkPrimaryColor,
          title: const Text('Graph'),
        ),
        body: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
                child: BarChart(_data()))));
  }

  BarChartData _data() {
    return BarChartData(
        barGroups: List.generate(3, (i) {
      switch (i) {
        case 0:
          return _makeGroupData(0, Random().nextInt(15).toDouble() + 6);
        case 1:
          return _makeGroupData(0, Random().nextInt(15).toDouble() + 6);
        case 2:
          return _makeGroupData(0, Random().nextInt(15).toDouble() + 6);
        default:
          throw Error();
      }
    }));
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
            toY: 20,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
