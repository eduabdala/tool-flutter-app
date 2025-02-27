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
import '../data/chart_data.dart';

/// @brief A widget that represents a custom line chart
/// 
/// This widget displays three sets of line data (min, mid, max) 
/// and allows for zooming and panning interactions.
class CustomChart extends StatelessWidget {
  final String chartName;
  final List<List<ChartData>> chartData; ///< Data points for minimum values
  final List<String>  chartDataName; ///< Label for the minimum data series
  final List<Color> chartDataColor; ///< Color for the minimum data series
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
  const CustomChart({super.key, 
    required this.chartName,
    required this.chartData,
    required this.chartDataName,
    required this.chartDataColor,
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
      title: ChartTitle(text: chartName),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        alignment: ChartAlignment.near,
      ),
      primaryXAxis: NumericAxis(
        visibleMinimum: chartData[0].isNotEmpty ? chartData[0].last.timestamp - 10 : null,
        visibleMaximum: chartData[0].isNotEmpty ? chartData[0].last.timestamp : null,
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
        for (int i = 0; i < chartData.length; i++)
          LineSeries<ChartData, double>(
            color: chartDataColor[i],
            dataSource: chartData[i],
            xValueMapper: (ChartData data, _) => data.timestamp,
            yValueMapper: (ChartData data, _) => data.value,
            name: chartDataName[i],
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

/** @} */
