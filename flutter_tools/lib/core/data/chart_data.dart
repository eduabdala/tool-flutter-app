class ChartData {
  final double timestamp;
  final double value;

  ChartData(this.timestamp, this.value);

  @override
  String toString() {
    return 'ChartData(timestamp: $timestamp, value: $value)';
  }
}
