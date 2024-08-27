import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomChart extends StatelessWidget {
  final List<ChartData> minData;
  final List<ChartData> midData;
  final List<ChartData> maxData;
  final String minDataName;
  final String midDataName;
  final String maxDataName;
  final Color minDataColor;
  final Color midDataColor;
  final Color maxDataColor;
  final double? Function() calculateYMin;
  final double? Function() calculateYMax;

  CustomChart({
    required this.minData,
    required this.midData,
    required this.maxData,
    this.minDataName = 'Min Data',
    this.midDataName = 'Mid Data',
    this.maxDataName = 'Max Data',
    this.minDataColor = Colors.blueAccent,
    this.midDataColor = Colors.red,
    this.maxDataColor = Colors.green,
    required this.calculateYMin,
    required this.calculateYMax, 
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        alignment: ChartAlignment.near,
      ),
      primaryXAxis: NumericAxis(
        visibleMinimum: minData.isNotEmpty ? minData.last.timestamp - 10 : null,
        visibleMaximum: minData.isNotEmpty ? minData.last.timestamp : null,
        labelFormat: '{value} s',
        interval: 5,
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          num numericValue = args.value;
          String formattedValue = '${(numericValue % 60).toStringAsFixed(1)} s';
          return ChartAxisLabel(formattedValue, TextStyle());
        },
      ),
      primaryYAxis: NumericAxis(
        visibleMinimum: calculateYMin(),
        visibleMaximum: calculateYMax(),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, double>(
          color: minDataColor,
          dataSource: minData,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: minDataName,
          markerSettings: MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartData, double>(
          color: midDataColor,
          dataSource: midData,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: midDataName,
          markerSettings: MarkerSettings(isVisible: true),
        ),
        LineSeries<ChartData, double>(
          color: maxDataColor,
          dataSource: maxData,
          xValueMapper: (ChartData data, _) => data.timestamp,
          yValueMapper: (ChartData data, _) => data.value,
          name: maxDataName,
          markerSettings: MarkerSettings(isVisible: true),
        ),
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enableDoubleTapZooming: true,
        enablePanning: true,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
      ),
    );
  }
}

class ChartData {
  final double value;
  final double timestamp;

  ChartData(this.value)
      : timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;

  @override
  String toString() {
    return 'ChartData(value: $value, timestamp: $timestamp)';
  }
}
