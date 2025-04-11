class SensorData {
  final String data;
  final String hora;
  final List<Map<String, dynamic>> sensors;

  SensorData({required this.data, required this.hora, required this.sensors});

  @override
  String toString() {
    return 'Data: $data, Hora: $hora, Sensores: $sensors';
  }
}
