import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/data/chart_data.dart';
import '../../../core/services/log_services.dart';
import '../../../core/services/serial_handler.dart';
import '../../../core/widgets/custom_chart_widget.dart';
import '../../../core/widgets/serial_widget.dart';
import '../blocs/chart_data_bloc.dart';
import '../blocs/chart_data_event.dart';

class SuChartAppSec extends StatefulWidget {
  @override
  _SerialChartAppState createState() => _SerialChartAppState();
}

class _SerialChartAppState extends State<SuChartAppSec> {
  // Controle de estado de conexão e modo
  bool isConnected = false;
  bool isRunning = false;
  bool isPdMode = false;

  // Variáveis para os dados dos sensores
  final Map<String, List<ChartData>> sensorGraphs = {
    'Sensor 1': [],
    'Sensor 2': [],
    'Sensor 3': [],
  };

  TextEditingController commandLineCLIController = TextEditingController();
  TextEditingController logWidgetController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  FocusNode logsFocusNode = FocusNode();
  final CsvLogger _csvLogger = CsvLogger();

  // Exemplo de dados dos sensores
  List<Map<String, dynamic>> sensorData = [
    {'tipo': 'c', 'valor1': '20', 'valor2': '30', 'valor3': '25'},
    {'tipo': 'c', 'valor1': '22', 'valor2': '32', 'valor3': '28'},
    {'tipo': 'o', 'valor1': '50', 'valor2': '60', 'valor3': '55'},
    {'tipo': 'o', 'valor1': '52', 'valor2': '62', 'valor3': '58'},
  ];

  @override
  void initState() {
    super.initState();
    SerialHandler.listAvailablePorts();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChartDataBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('SU Data Chart - firmwareVersion'),
          actions: [
            IconButton(
              tooltip: 'Logs',
              icon: Icon(Icons.download),
              onPressed: () {
                // Lógica para download de logs, se necessário
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: 
              SerialCommunicationPanel(
                  extraButtons: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isConnected ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        
                      },
                      child: Text(isConnected ? "Connected" : "Disconnected"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (isRunning) {
                          context.read<ChartDataBloc>().add(
                                StopGraphEvent(true, true),
                              );
                        } else {
                          context.read<ChartDataBloc>().add(
                                StartGraphEvent(true, 'status csv *'),
                              );
                        }
                      },
                      child: Icon(
                        isRunning ? Icons.stop : Icons.play_arrow,
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPdMode ? Colors.blue : Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isPdMode = !isPdMode;
                        });
                      },
                      child: Text(isPdMode ? "PD" : "CLI"),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
       
        )],
        ),
      ),
    );
  }
}
