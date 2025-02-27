import 'sensor_data.dart';

class AntiskimmingChartData {
  String data;
  String hora;
  List<SensorData> sensor;

  AntiskimmingChartData({
    required this.data,
    required this.hora,
    required this.sensor,
  });

  @override
  String toString() {
    String sensorDetails = sensor.map((s) => s.toString()).join(', ');
    return 'AntiskimmingChartData(data: $data, hora: $hora, sensors: [$sensorDetails])';
  }
}