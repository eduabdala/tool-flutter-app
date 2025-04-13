import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/serial_handler.dart';

class SuChartApp extends StatefulWidget {
  const SuChartApp({super.key});

  @override
  _SerialChartAppState createState() => _SerialChartAppState();
}

class _SerialChartAppState extends State<SuChartApp> {
  List<List<ChartData>> dynamicData = [];
  List<List<ChartData>> dynamicInData = [];
  List<List<ChartData>> dynamicInnData = [];
  Map<String, SensorData> sensorDataMap = {};
  List<SensorData> sensorDataList = [];
  SerialHandler? serialHandler;
  TextEditingController commandLineCLIController = TextEditingController();
  TextEditingController logWidgetController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  FocusNode logsFocusNode = FocusNode();
  int activeZones = 3;
  String nameZone = 'Unknown';
  String? selectedPort;
  List<String> availablePorts = [];
  bool isPdMode = true;
  Timer? sendTimer;
  bool flag = false;
  String? firmwareVersion = 'Unknown';
  bool isConnected = false;
  bool isRunning = true;
  bool isProcessingCommand = false;
  double timerInterval = 400.0;
  double timeWindow = 50.0;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _listAvailablePorts();
  }

  @override
  void dispose() {
    serialHandler?.closeConnection();
    sendTimer?.cancel();
    commandLineCLIController.dispose();
    logWidgetController.dispose();
    scrollController.dispose();
    logsFocusNode.dispose();

    super.dispose();
  }

  void _listAvailablePorts() {
    availablePorts = SerialPort.availablePorts;
    if (availablePorts.isNotEmpty) {
      setState(() {
        selectedPort = availablePorts.first;
      });
    }
  }

  void _toggleConnection() {
    if (isConnected) {
      sendTimer?.cancel();
      serialHandler?.closeConnection();
      setState(() {
        flag = false;
        isRunning = true;
        isConnected = false;
        logWidgetController.text += 'Disconnected\n';
        firmwareVersion = "Unknown";
      });
    } else {
      if (selectedPort != null) {
        serialHandler = SerialHandler(selectedPort!);
        int result = serialHandler!.openConnection();
        logWidgetController.text += 'Trying to connect to $selectedPort...\n';
        if (result == 0) {
          setState(() {
            isConnected = true;
            logWidgetController.text += 'Connected to $selectedPort\n';
          });
        } else {
          setState(() {
            logWidgetController.text += 'Failed to connect to $selectedPort\n';
          });
        }
      }
    }
  }

  void _toggleGraph() {
    if (isRunning) {
      String command = 'status csv *\n';
      setState(() {
        flag = true;
        isRunning = false;
      });

      if (!isConnected) {
        setState(() {
          logWidgetController.text += 'No connection established\n';
          flag = false;
          isRunning = true;
        });
        return;
      }

      sendTimer?.cancel();
      sendTimer = Timer.periodic(Duration(milliseconds: timerInterval.toInt()),
          (sendTmer) async {
        if (!isProcessingCommand) {
          try {
            if (serialHandler != null) {
              String? response = await serialHandler?.sendData(command);

              if (response != null && response.isNotEmpty) {
                response = response.substring(1, response.length - 1);
                SensorData sensorData = SensorData.fromResponse(response);
                setState(() {
                  sensorDataList = [sensorData];
                });
              } else {
                setState(() {
                  logWidgetController.text +=
                      'No response received or response is empty.\n';
                });
              }
            } else {
              setState(() {
                logWidgetController.text += 'Serial handler is null.\n';
              });
            }
          } catch (e) {
            setState(() {
              logWidgetController.text += 'Error sending command: $e\n';
            });
          }
        }
      });
    } else {
      sendTimer?.cancel();
      setState(() {
        flag = false;
        isRunning = true;
      });
    }
  }

  void _toggleCmdMode() {
    if (isPdMode) {
      setState(() {
        isPdMode = false;
      });
    } else {
      setState(() {
        isPdMode = true;
      });
    }
  }

  String _calculateBCC(String command) {
    int bcc = 0;
    for (int i = 0; i < command.length; i++) {
      bcc ^= command.codeUnitAt(i);
    }
    return String.fromCharCode(bcc);
  }

  void executeCommand() async {
    String command;

    if (serialHandler == null) {
      setState(() {
        logWidgetController.text += 'No connection established\n';
      });
      return;
    }
    if (isPdMode) {
      String commandAsn = "\x02${commandLineCLIController.text}\x03";
      String bcc = _calculateBCC(commandAsn);
      command = commandAsn + bcc;
    } else {
      command = "${commandLineCLIController.text}\n";
    }
    setState(() {
      logWidgetController.text += 'Sending: $command\n';
    });
    setState(() {
      isProcessingCommand = true;
    });
    String? response = await serialHandler?.sendData(command);
    if (response != null) {
      setState(() {
        logWidgetController.text += 'Received: $response\n';
      });
    } else {
      setState(() {
        logWidgetController.text += 'No response\n';
      });
    }
    setState(() {
      isProcessingCommand = false;
      commandLineCLIController.clear();
    });
  }

  void _updateTimerInterval(double intervalMs) {
    if (sendTimer != null) {
      sendTimer?.cancel();
    }

    setState(() {
      timerInterval = intervalMs;
    });
  }

  void _updateTimeWindow(double newWindowSize) {
    setState(() {
      timeWindow = newWindowSize;
    });
  }

  Future<void> _getConfig() async {
    String commandAsn = "\x02i\x03";
    String bcc = _calculateBCC(commandAsn);
    String command = commandAsn + bcc;
    try {
      logWidgetController.text += "Getting config...\n";
      String? response = await serialHandler?.sendData(command);
      if (response != null) {
        response = response.substring(3, 11);
        logWidgetController.text += "Firwmare Version: $response\n";
        setState(() {
          firmwareVersion = response;
        });
        _getZone();
      } else {
        setState(() {
          logWidgetController.text += 'No response\n';
        });
      }
    } catch (e) {
      logWidgetController.text += 'Error to get config: $e\n';
    }
  }

  Future<void> _getZone() async {
    String commandAsn = "\x02S\x03";
    String bcc = _calculateBCC(commandAsn);
    String command = commandAsn + bcc;
    try {
      String? response = await serialHandler?.sendData(command);
      if (response != null) {
        List<String> parts = response.split('|');

        if (parts.length > 1) {
          String zoneData = parts[3];
          int activeZones =
              zoneData.split('').where((char) => char != 'N').length;

          logWidgetController.text += 'Number of active zones: $activeZones\n';
          setState(() {
            this.activeZones = activeZones;
          });
        } else {
          setState(() {
            logWidgetController.text +=
                'Unexpected response format: $response.\n';
          });
        }
      } else {
        setState(() {
          logWidgetController.text += 'No response\n';
        });
      }
    } catch (e) {
      logWidgetController.text += 'Erro: $e\n';
    }
  }

  // Função para gerar gráficos a partir do CSV (como discutido anteriormente)

  void _updateChartData(String data) {
    List<String> parts = data.split(';');
    if (parts.length >= 10) {
      setState(() {
        // Adiciona novos dados às listas de forma dinâmica
        for (int i = 6; i <= 8; i++) {
          if (i - 6 >= dynamicData.length) {
            dynamicData.add([]);
          }
          dynamicData[i - 6].add(ChartData(double.parse(parts[i])));
        }
        for (int i = 12; i <= 15; i++) {
          if (i - 12 >= dynamicInData.length) {
            dynamicInData.add([]);
          }
          dynamicInData[i - 12].add(ChartData(double.parse(parts[i])));
        }
        for (int i = 18; i <= 22; i++) {
          if (i - 18 >= dynamicInnData.length) {
            dynamicInnData.add([]);
          }
          dynamicInnData[i - 18].add(ChartData(double.parse(parts[i])));
        }
      });

      int maxDataPoints = timeWindow.toInt();
      for (var dataList in dynamicData) {
        _trimExcessData(dataList, maxDataPoints);
      }
      for (var dataList in dynamicInData) {
        _trimExcessData(dataList, maxDataPoints);
      }

      // Limite de dados para evitar overflow
      if (dynamicData.any((dataList) => dataList.length > 50)) {
        setState(() {
          for (var dataList in dynamicData) {
            if (dataList.length > 50) {
              dataList.removeRange(0, dataList.length - 50);
            }
          }
          for (var dataList in dynamicInData) {
            if (dataList.length > 50) {
              dataList.removeRange(0, dataList.length - 50);
            }
          }
        });
      }
    }
  }

  void _trimExcessData(List<ChartData> dataList, int maxDataPoints) {
    if (dataList.length > maxDataPoints) {
      setState(() {
        dataList.removeRange(0, dataList.length - maxDataPoints);
      });
    }
  }

  List<Widget> _generateChartWidgets() {
    List<Widget> chartWidgets = [];

    chartWidgets.add(
      Expanded(
        child: CustomChart(
          zoneName: 'otico',
          dataSeries:
              dynamicData, // Passa uma lista vazia para garantir que começa vazio
          dataNames: const ['Min Value', 'Value', 'Max Value'],
          calculateYMin: _calculateYMin,
          calculateYMax: _calculateYMax,
        ),
      ),
    );

    chartWidgets.add(
      Expanded(
        child: CustomChart(
          zoneName: 'otico',
          dataSeries:
              dynamicInnData, // Passa uma lista vazia para garantir que começa vazio
          dataNames: const ['Min Value', 'Value', 'Max Value'],
          calculateYMin: _calculateYMin,
          calculateYMax: _calculateYMax,
        ),
      ),
    );

    // Adiciona gráficos óticos conforme necessário (também começam vazios)
    for (int i = 1; i < activeZones; i++) {
      chartWidgets.add(
        Expanded(
          child: CustomChart(
            zoneName: 'otico',
            dataSeries: dynamicInData, // Lista vazia inicial
            dataNames: const ['Min Value', 'Value', 'Max Value'],
            calculateYMin: _calculateYMinIn,
            calculateYMax: _calculateYMaxIn,
          ),
        ),
      );
      if (i < activeZones - 1) {
        chartWidgets.add(const SizedBox(width: 10));
      }
    }

    return chartWidgets;
  }

  double? _calculateYMin() {
    List<double> allValues = dynamicData
        .expand((dataList) => dataList.map((data) => data.value))
        .toList();
    if (allValues.isEmpty) return null;
    double minValue = allValues.reduce((a, b) => a < b ? a : b);
    double margin =
        (allValues.reduce((a, b) => a > b ? a : b) - minValue) * 0.2;
    return minValue - margin;
  }

  double? _calculateYMax() {
    List<double> allValues = dynamicData
        .expand((dataList) => dataList.map((data) => data.value))
        .toList();
    if (allValues.isEmpty) return null;
    double maxValue = allValues.reduce((a, b) => a > b ? a : b);
    double margin =
        (maxValue - allValues.reduce((a, b) => a < b ? a : b)) * 0.2;
    return maxValue + margin;
  }

  double? _calculateYMinIn() {
    List<double> allValues = dynamicInData
        .expand((dataList) => dataList.map((data) => data.value))
        .toList();
    if (allValues.isEmpty) return null;
    double minValue = allValues.reduce((a, b) => a < b ? a : b);
    double margin =
        (allValues.reduce((a, b) => a > b ? a : b) - minValue) * 0.2;
    return minValue - margin;
  }

  double? _calculateYMaxIn() {
    List<double> allValues = dynamicInData
        .expand((dataList) => dataList.map((data) => data.value))
        .toList();
    if (allValues.isEmpty) return null;
    double maxValue = allValues.reduce((a, b) => a > b ? a : b);
    double margin =
        (maxValue - allValues.reduce((a, b) => a < b ? a : b)) * 0.2;
    return maxValue + margin;
  }

  void _clearCharts() {
    setState(() {
      for (var dataList in dynamicData) {
        dataList.clear();
        dataList.add(ChartData(0)); // Adiciona o valor 0 após limpar
      }

      for (var dataList in dynamicInData) {
        dataList.clear();
        dataList.add(ChartData(0)); // Adiciona o valor 0 após limpar
      }
    });
  }

  Future<void> _calibrating() async {
    String commandAsn = "\x02C\x03";
    String bcc = _calculateBCC(commandAsn);
    String command = commandAsn + bcc;
    try {
      logWidgetController.text += "Getting config...\n";
      String? response = await serialHandler?.sendData(command);
      if (response != null) {
        response = response.substring(3, 11);
        logWidgetController.text += "Firwmare Version: $response\n";
        setState(() {
          firmwareVersion = response;
        });
        _getZone();
      } else {
        setState(() {
          logWidgetController.text += 'No response\n';
        });
      }
    } catch (e) {
      logWidgetController.text += 'Error to get config: $e\n';
    }
  }

  void _clearLogs() {
    setState(() {
      logWidgetController.clear();
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Chart - $firmwareVersion'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Itera sobre a lista de sensores e cria um widget para cada sensor
                  for (var sensorData in sensorDataList)
                    for (var sensor in sensorData.sensors)
                      SensorChartWidget(
                          sensor:
                              sensor), // Passando um sensor, não o sensorData
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("COM: "),
                DropdownButton<String>(
                  value: selectedPort,
                  items: availablePorts
                      .map((port) => DropdownMenuItem<String>(
                            value: port,
                            child: Text(port),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPort = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _listAvailablePorts,
                  child: const Icon(
                    Icons.refresh,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleConnection,
                  child: Text(isConnected ? "Connected" : "Disconnected"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleGraph,
                  child: Icon(
                    isRunning ? Icons.play_arrow : Icons.pause,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPdMode ? Colors.blue : Colors.purpleAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleCmdMode,
                  child: Text(isPdMode ? "PD" : "CLI"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _clearCharts,
                  child: const Icon(
                    Icons.cleaning_services,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _calibrating,
                  child: const Icon(
                    Icons.build,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Timer Interval (ms):"),
                    const SizedBox(height: 5),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: timerInterval,
                        min: 300.0,
                        max: 2000.0,
                        divisions: 17,
                        label: '${timerInterval.toInt()} ms',
                        onChanged: (value) {
                          setState(() {
                            timerInterval = value;
                            _updateTimerInterval(timerInterval);
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Time Window (samples):"),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 200,
                    child: Slider(
                      value: timeWindow,
                      min: 20.0,
                      max: 100.0,
                      divisions: 8,
                      label: '${timeWindow.toInt()} samples',
                      onChanged: (value) {
                        setState(() {
                          timeWindow = value;
                          _updateTimeWindow(timeWindow);
                        });
                      },
                    ),
                  ),
                ])
              ],
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: commandLineCLIController,
                    decoration: const InputDecoration(
                      labelText: 'Enter command',
                    ),
                    onSubmitted: (value) {
                      if (value == 'clear') {
                        _clearLogs();
                      } else {
                        if (flag == true) {
                          executeCommand();
                          if (isProcessingCommand == false &&
                              isRunning == false) {
                            _toggleGraph();
                          }
                        } else {
                          executeCommand();
                        }
                      }
                    },
                  ),
                  Expanded(
                    child: Listener(
                      onPointerDown: (_) {
                        logsFocusNode.requestFocus();
                      },
                      child: Focus(
                        focusNode: logsFocusNode,
                        onKey: (FocusNode node, RawKeyEvent event) {
                          if (event is RawKeyDownEvent) {
                            if (event.isControlPressed &&
                                event.logicalKey == LogicalKeyboardKey.keyL) {
                              _clearLogs();
                            }
                          }
                          return KeyEventResult.ignored;
                        },
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: TextField(
                            controller: logWidgetController,
                            maxLines: null,
                            enabled: false,
                            decoration: const InputDecoration.collapsed(
                              hintText: 'Serial Logs',
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _scrollToEnd();
  }
}

/***********************************************************************
 * $Id$        custom_chart.dart             2024-09-24
 */ /**
 * @file        custom_chart.dart
 * @brief       A widget for displaying a custom line chart
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/

/// @brief A widget that represents a custom line chart
///
/// This widget displays three sets of line data (min, mid, max)
/// and allows for zooming and panning interactions.

class CustomChart extends StatefulWidget {
  final String zoneName;
  final List<List<ChartData>> dataSeries; // Lista de listas de ChartData
  final List<String> dataNames; // Lista de nomes para as séries de dados
  final double? Function() calculateYMin;
  final double? Function() calculateYMax;

  const CustomChart({super.key, 
    required this.zoneName,
    required this.dataSeries,
    required this.dataNames,
    required this.calculateYMin,
    required this.calculateYMax,
  });

  @override
  _CustomChartState createState() => _CustomChartState();
}

class _CustomChartState extends State<CustomChart> {
  bool isLoading = true; // Estado de carregamento

  @override
  Widget build(BuildContext context) {
    try {
      // Validar entradas para garantir que as listas têm o mesmo tamanho
      if (widget.dataSeries.length != widget.dataNames.length) {
        // Ajustar tamanho das listas para serem iguais, preenchendo com dados zerados
        int maxLength = widget.dataSeries.length > widget.dataNames.length
            ? widget.dataSeries.length
            : widget.dataNames.length;

        // Preencher a lista dataNames com valores padrão (se necessário)
        while (widget.dataNames.length < maxLength) {
          widget.dataNames.add('Serie ${widget.dataNames.length + 1}');
        }

        // Preencher a lista dataSeries com listas de ChartData vazias (zeradas)
        while (widget.dataSeries.length < maxLength) {
          widget.dataSeries.add([
            ChartData(0), // Dados zerados
          ]);
        }
      }

      // Lista de cores automáticas
      List<Color> autoColors = [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.cyan,
        Colors.pink,
        Colors.yellow,
      ];

      List<CartesianSeries> seriesList = [];

      // Criar uma série para cada conjunto de dados
      for (int series = 0; series < widget.dataSeries.length; series++) {
        Color color = autoColors[
            series % autoColors.length]; // Seleciona uma cor automática

        seriesList.add(
          LineSeries<ChartData, double>(
            color: color,
            dataSource: widget.dataSeries[series],
            xValueMapper: (ChartData data, _) => data.timestamp,
            yValueMapper: (ChartData data, _) => data.value,
            name: widget.dataNames[series],
            markerSettings: const MarkerSettings(
                isVisible: false,
                width: 5,
                height: 5), // Ajuste do tamanho do marcador
          ),
        );
      }

      // Após processar os dados, mudar o estado de carregamento para false
      setState(() {
        isLoading = false;
      });

      return isLoading
          ? const Center(child: CircularProgressIndicator()) // Exibe o carregamento
          : SfCartesianChart(
              title: ChartTitle(text: widget.zoneName),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                alignment: ChartAlignment.near,
              ),
              primaryXAxis: NumericAxis(
                visibleMinimum: widget.dataSeries.isNotEmpty
                    ? widget.dataSeries[0].last.timestamp - 10
                    : null,
                visibleMaximum: widget.dataSeries.isNotEmpty
                    ? widget.dataSeries[0].last.timestamp
                    : null,
                labelFormat: '{value} s',
                interval: 5,
                axisLabelFormatter: (AxisLabelRenderDetails args) {
                  num numericValue = args.value;
                  String formattedValue =
                      '${(numericValue % 60).toStringAsFixed(1)} s';
                  return ChartAxisLabel(formattedValue, const TextStyle());
                },
              ),
              primaryYAxis: NumericAxis(
                visibleMinimum: widget.calculateYMin(),
                visibleMaximum: widget.calculateYMax(),
              ),
              series: seriesList,
              zoomPanBehavior: ZoomPanBehavior(
                enablePinching: true,
                enableDoubleTapZooming: true,
                enablePanning: true,
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
              ),
            );
    } catch (e) {
      // Em caso de erro, mostrar um gráfico vazio
      return SfCartesianChart(
        title: ChartTitle(text: widget.zoneName),
        series: const [], // Gráfico vazio
        primaryXAxis: NumericAxis(),
        primaryYAxis: NumericAxis(),
      );
    }
  }
}

class ChartData {
  final double value;

  final double timestamp;

  ChartData(this.value)
      : timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;

  @override
  String toString() {
    return 'ChartData(value: $value, timestamp: $timestamp)';
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

  static SensorData fromResponse(String csvLine) {
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
class SensorValue {
  final DateTime timestamp;  // Timestamp para o eixo X
  final double value;  // Valor do sensor

  SensorValue(this.timestamp, this.value);
}
class SensorChartWidget extends StatelessWidget {
  final Sensor sensor;

  const SensorChartWidget({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${sensor.type} Zona ${sensor.zone}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Estado: ${sensor.state}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              height: 100,
              padding: const EdgeInsets.all(8),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
                  // Série para o minValue com timestamp
                  LineSeries<SensorValue, String>(
                    name: 'Min Value',
                    dataSource: _createChartData(sensor, 0),
                    xValueMapper: (SensorValue value, _) =>  _formatDate(value.timestamp), // Usando timestamp no eixo X
                    yValueMapper: (SensorValue value, _) => value.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  // Série para o value com timestamp
                  LineSeries<SensorValue, String>(
                    name: 'Value',
                    dataSource: _createChartData(sensor, 1),
                    xValueMapper: (SensorValue value, _) =>  _formatDate(value.timestamp), // Usando timestamp no eixo X
                    yValueMapper: (SensorValue value, _) => value.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  // Série para o maxValue com timestamp
                  LineSeries<SensorValue, String>(
                    name: 'Max Value',
                    dataSource: _createChartData(sensor, 2),
                    xValueMapper: (SensorValue value, _) =>  _formatDate(value.timestamp), // Usando timestamp no eixo X
                    yValueMapper: (SensorValue value, _) => value.value,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Cria os dados para o gráfico, usando um timestamp crescente no eixo X
  List<SensorValue> _createChartData(Sensor sensor, int valueType) {
    DateTime now = DateTime.now(); // Obtendo o timestamp atual

    // Gerar uma lista de dados com um timestamp crescente
    return [
      SensorValue(now.add(const Duration(seconds: 0)), sensor.values[0].toDouble()), // minValue
      SensorValue(now.add(const Duration(seconds: 1)), sensor.values[1].toDouble()), // value
      SensorValue(now.add(const Duration(seconds: 2)), sensor.values[2].toDouble()), // maxValue
    ];
  }
    // Função para formatar o DateTime para String (exemplo: "HH:mm:ss")
  String _formatDate(DateTime timestamp) {
    return DateFormat('HH:mm:ss').format(timestamp); // Formato de hora
  }
}


/** @} */
