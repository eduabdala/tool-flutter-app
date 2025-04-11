import 'chart_data.dart';
class SensorData {
  String tipo;
  String id;
  String status;
  ChartData mid;
  ChartData high;
  ChartData low;
  List<ChartData> extras;

  SensorData({
    required this.tipo,
    required this.id,
    required this.status,
    required this.mid,
    required this.high,
    required this.low,
    required this.extras,
  });

  @override
  String toString() {
    return 'SensorData(tipo: $tipo, id: $id, status: $status, '
        'mid: ${mid.toString()}, high: ${high.toString()}, low: ${low.toString()}, '
        'extras: [${extras.map((e) => e.toString()).join(', ')}])';
  }
}
