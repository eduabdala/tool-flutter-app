import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SensorChartScreen(),
    );
  }
}

class SensorChartScreen extends StatefulWidget {
  @override
  _SensorChartScreenState createState() => _SensorChartScreenState();
}

class _SensorChartScreenState extends State<SensorChartScreen> {
  List<SensorData> sensorDataList = [];
  
  @override
  void initState() {
    super.initState();

    // Simula dados recebidos (normalmente, você faria isso com dados em tempo real)
    String rawData =
        ";01/01/2000;17:11:55;c;1;A;56686;57891;58784;x;0;x;00000;00000;00000;o;1;U;00800;01779;36000;o;2;U;00800;01779;36000;c;1;A;56686;57891;58784;x;0;x;00000;00000;00000;o;1;U;00800;01779;36000;o;2;U;00800;01779;36000;";
    
    rawData = rawData.substring(1, rawData.length - 1);
    SensorData sensorData = SensorData.fromCSV(rawData);
    setState(() {
      sensorDataList = [sensorData];  // Adiciona os dados simulados à lista
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gráficos em Tempo Real')),
      body: ListView.builder(
        itemCount: sensorDataList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              for (var sensor in sensorDataList[index].sensors)
                SensorChartWidget(sensor: sensor),
            ],
          );
        },
      ),
    );
  }
}

class SensorChartWidget extends StatelessWidget {
  final Sensor sensor;
  const SensorChartWidget({required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sensor.type} Zona ${sensor.zone}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Estado: ${sensor.state}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      FlSpot(0, sensor.values[0].toDouble()),  // minValue
                      FlSpot(1, sensor.values[1].toDouble()),  // value
                      FlSpot(2, sensor.values[2].toDouble()),  // maxValue
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    belowBarData: BarAreaData(show: true),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class SensorData {
  final String date;
  final String time;
  final List<Sensor> sensors;

  SensorData({
    required this.date,
    required this.time,
    required this.sensors,
  });

  static SensorData fromCSV(String csvLine) {
    List<String> fields = csvLine.split(';');

    String date = fields[0];
    String time = fields[1];

    List<Sensor> sensors = [];
    for (int i = 2; i < fields.length; i++) {
      if (i + 5 < fields.length) {
        String sensorType = fields[i];

        if (sensorType == "x") {
          i += 5;
          continue;
        }

        String sensorZone = fields[i + 1];
        String sensorState = fields[i + 2];

        if (sensorZone == "x" || sensorState == "00000") continue;

        List<int> sensorValues = [
          parseInt(fields[i + 3]),
          parseInt(fields[i + 4]),
          parseInt(fields[i + 5]),
        ];

        String sensorName = sensorType == "c" ? "Capacitivo" : "Ótico";

        String stateDescription = sensorState == "A" ? "Ausente" : "Detectado";

        sensors.add(Sensor(
          type: sensorName,
          zone: sensorZone,
          state: stateDescription,
          values: sensorValues,
        ));

        i += 5;
      }
    }

    return SensorData(
      date: date,
      time: time,
      sensors: sensors,
    );
  }

  static int parseInt(String value) {
    try {
      return int.parse(value);
    } catch (e) {
      return 0;
    }
  }
}

class Sensor {
  final String type;
  final String zone;
  final String state;
  final List<int> values;

  Sensor({
    required this.type,
    required this.zone,
    required this.state,
    required this.values,
  });

  @override
  String toString() {
    return 'Tipo: $type, Zona: $zone, Estado: $state, Valores: $values';
  }
}
