import 'dart:core';
import '../data/antiskimming_chart_data.dart';
import '../data/chart_data.dart';
import '../data/sensor_data.dart';

AntiskimmingChartData parseAntiskimmingData(String data) {
  List<dynamic> tokens = data.split(';').where((e) => e.isNotEmpty).toList();

  if (tokens.length < 2) {
    throw FormatException("Linha de dados incompleta!");
  }

  AntiskimmingChartData result = AntiskimmingChartData(
    data: tokens[0],
    hora: tokens[1],
    sensor: [],
  );

  DateTime now = DateTime.now();
  double timestampInMillis = now.millisecondsSinceEpoch.toDouble();

  Set<String> tiposValidos = {'c', 'o', 'x', 'z'};

  int i = 2;
  while (i < tokens.length) {
    if (tiposValidos.contains(tokens[i])) {
      double midValue = double.tryParse(tokens[i + 3]) ?? 0.0;
      double highValue = double.tryParse(tokens[i + 4]) ?? 0.0;
      double lowValue = double.tryParse(tokens[i + 5]) ?? 0.0;

      SensorData reg = SensorData(
        tipo: tokens[i],
        id: tokens[i + 1],
        status: tokens[i + 2],
        mid: ChartData(timestampInMillis, midValue),
        high: ChartData(timestampInMillis, highValue),
        low: ChartData(timestampInMillis, lowValue),
        extras: [],
      );

      i += 5;

      while (i < tokens.length && !tiposValidos.contains(tokens[i])) {
        double extraValue = double.tryParse(tokens[i]) ?? 0.0;
        reg.extras.add(ChartData(timestampInMillis, extraValue));
        i++;
      }

      result.sensor.add(reg);
    } else {
      i++;
    }
  }

  return result;
}
