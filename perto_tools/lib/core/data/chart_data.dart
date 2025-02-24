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
      : timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0 ;

  @override
  String toString() {
    return 'ChartData(value: $value, timestamp: $timestamp)';
  }
}