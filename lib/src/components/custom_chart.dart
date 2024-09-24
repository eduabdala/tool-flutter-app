/***********************************************************************
 * $Id$        custom_chart.dart             2024-09-24
 *//**
 * @file        custom_chart.dart
 * @brief       A widget for displaying a custom line chart
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  CustomChart Custom Chart Widget
/// @{
library;


import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// @brief A widget that represents a custom line chart
/// 
/// This widget displays three sets of line data (min, mid, max) 
/// and allows for zooming and panning interactions.
class CustomChart extends StatelessWidget {
  final List<ChartData> minData; ///< Data points for minimum values
  final List<ChartData> midData; ///< Data points for mid-range values
  final List<ChartData> maxData; ///< Data points for maximum values
  final String minDataName; ///< Label for the minimum data series
  final String midDataName; ///< Label for the mid data series
  final String maxDataName; ///< Label for the maximum data series
  final Color minDataColor; ///< Color for the minimum data series
  final Color midDataColor; ///< Color for the mid data series
  final Color maxDataColor; ///< Color for the maximum data series
  final double? Function() calculateYMin; ///< Function to calculate minimum Y-axis value
  final double? Function() calculateYMax; ///< Function to calculate maximum Y-axis value

  /// @brief Constructor for CustomChart
  /// 
  /// Initializes the chart with the provided data and visual configurations.
  /// 
  /// @param minData List of ChartData for the minimum values
  /// @param midData List of ChartData for the mid-range values
  /// @param maxData List of ChartData for the maximum values
  /// @param minDataName Name for the minimum data series
  /// @param midDataName Name for the mid-range data series
  /// @param maxDataName Name for the maximum data series
  /// @param minDataColor Color for the minimum data series
  /// @param midDataColor Color for the mid-range data series
  /// @param maxDataColor Color for the maximum data series
  /// @param calculateYMin Function to determine the minimum Y-axis value
  /// @param calculateYMax Function to determine the maximum Y-axis value
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

  /// @brief Builds the line chart widget
  /// 
  /// This method constructs the SfCartesianChart with the defined 
  /// data series, axes configurations, and interactive behaviors.
  /// 
  /// @param context The build context for the widget
  /// @return Widget Returns the SfCartesianChart widget
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

/// @brief A class representing data points for the chart
/// 
/// This class contains a value and a timestamp for each data point.
class ChartData {
  final double value; ///< The value of the data point
  final double timestamp; ///< The timestamp of the data point

  /// @brief Constructor for ChartData
  /// 
  /// Initializes a ChartData instance with a value and the current timestamp.
  /// 
  /// @param value The value for this data point
  ChartData(this.value)
      : timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;

  @override
  String toString() {
    return 'ChartData(value: $value, timestamp: $timestamp)';
  }
}
/** @} */
