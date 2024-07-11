import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum CommandMode {
  ASCII,
  Hexadecimal,
}

class SuChartApp extends StatefulWidget {
  @override
  _SerialChartAppState createState() => _SerialChartAppState();
}

class _SerialChartAppState extends State<SuChartApp> {
  List<ChartData> minData = [];
  List<ChartData> midData = [];
  List<ChartData> maxData = [];
  List<ChartData> inMinData = [];
  List<ChartData> inMidData = [];
  List<ChartData> inMaxData = [];
  SerialPort? port;
  SerialPortReader? reader;
  StreamSubscription<String>? subscription;
  TextEditingController commandController = TextEditingController();
  TextEditingController logsController = TextEditingController();
  List<String> availablePorts = [];
  String? selectedPort;
  bool isPortOpen = false;
  bool isPlaying = false;
  bool isPdMode = false;
  CommandMode commandMode = CommandMode.ASCII;
  Timer? sendTimer;
  bool isLogging = false;

  @override
  void initState() {
    super.initState();
    _initializeSerialPort();
  }

  void _initializeSerialPort() {
    availablePorts = SerialPort.availablePorts;
    if (availablePorts.isNotEmpty) {
      selectedPort = availablePorts[0];
    } else {
      print('No available serial ports.');
    }
  }

  void _openPort() {
    if (selectedPort != null && port == null) {
      port = SerialPort(selectedPort!);
      if (port!.openReadWrite()) {
        reader = SerialPortReader(port!);
        subscription = reader!.stream.map(utf8.decode).listen(_onDataReceived);
        setState(() {
          isPortOpen = true;
        });
        _logMessage('Port $selectedPort opened.');
      } else {
        _logMessage(
            'Failed to open port $selectedPort: ${SerialPort.lastError}');
      }
    }
  }

  void _closePort() {
    subscription?.cancel();
    port?.close();
    port = null;
    if (mounted) {
      setState(() {
        isPortOpen = false;
        isPlaying = false;
      });
    }
    _logMessage('Port $selectedPort closed.');
  }

  double? _calculateYMin() {
    List<double> allValues = [
      ...minData.map((data) => data.value),
      ...midData.map((data) => data.value),
      ...maxData.map((data) => data.value)
    ];

    if (allValues.isEmpty) return null;

    double minValue = allValues.reduce((a, b) => a < b ? a : b);
    double margin =
        (allValues.reduce((a, b) => a > b ? a : b) - minValue) * 0.2;
    return minValue - margin;
  }

  double? _calculateYMax() {
    List<double> allValues = [
      ...minData.map((data) => data.value),
      ...midData.map((data) => data.value),
      ...maxData.map((data) => data.value)
    ];

    if (allValues.isEmpty) return null;

    double maxValue = allValues.reduce((a, b) => a > b ? a : b);
    double margin =
        (maxValue - allValues.reduce((a, b) => a < b ? a : b)) * 0.2;
    return maxValue + margin;
  }

  double? _calculateYMinIn() {
    List<double> allValues = [
      ...inMinData.map((data) => data.value),
      ...inMidData.map((data) => data.value),
      ...inMaxData.map((data) => data.value)
    ];

    if (allValues.isEmpty) return null;

    double minValue = allValues.reduce((a, b) => a < b ? a : b);
    double margin =
        (allValues.reduce((a, b) => a > b ? a : b) - minValue) * 0.2;
    return minValue - margin;
  }

  double? _calculateYMaxIn() {
    List<double> allValues = [
      ...inMinData.map((data) => data.value),
      ...inMidData.map((data) => data.value),
      ...inMaxData.map((data) => data.value)
    ];

    if (allValues.isEmpty) return null;

    double maxValue = allValues.reduce((a, b) => a > b ? a : b);
    double margin =
        (maxValue - allValues.reduce((a, b) => a < b ? a : b)) * 0.2;
    return maxValue + margin;
  }

  void _sendCommand() {
    if (port != null && isPortOpen) {
      String command = commandController.text.trim();
      if (isPdMode) {
        String fullCommand = "\x02$command\x03";
        String bcc = _calculateBCC(fullCommand);
        String fullCommandWithBCC = fullCommand + bcc;

        if (commandMode == CommandMode.Hexadecimal) {
          List<int> bytes = _parseHexString(fullCommandWithBCC);
          port!.write(Uint8List.fromList(bytes));
          _logMessage(
              'Sent command in hexadecimal (pd mode): $fullCommandWithBCC');
        } else {
          port!.write(
              Uint8List.fromList(utf8.encode(fullCommandWithBCC + '\n')));
          _logMessage('Sent command in ASCII (pd mode): $fullCommandWithBCC');
        }
      } else {
        if (commandMode == CommandMode.Hexadecimal) {
          List<int> bytes = _parseHexString(command);
          port!.write(Uint8List.fromList(bytes));
          _logMessage('Sent command in hexadecimal: $command');
        } else {
          port!.write(Uint8List.fromList(utf8.encode(command + '\n')));
          _logMessage('Sent command in ASCII: $command');
        }
      }
      commandController.clear();
    } else {
      _logMessage('Port not open. Cannot send command.');
    }
  }

  List<int> _parseHexString(String hexString) {
    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String hex = hexString.substring(i, i + 2);
      bytes.add(int.parse(hex, radix: 16));
    }
    return bytes;
  }

  String _calculateBCC(String command) {
    int bcc = 0;
    for (int i = 0; i < command.length; i++) {
      bcc ^= command.codeUnitAt(i);
    }
    return String.fromCharCode(bcc);
  }

  Future<void> _onDataReceived(String data) async {
    // Exibir o dado recebido no log da aplicação
    _logMessage(data);
    // Atualizar os gráficos com os dados recebidos
    _updateChartData(data);
    // Verificar se o modo de logging está ativado
    if (isLogging) {
      // Obter o diretório de downloads usando path_provider
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        _logMessage('Erro ao obter o diretório de Downloads.');
        return;
      }

      // Criar o caminho completo do arquivo de logs
      final file = File('${downloadsDirectory.path}\\logs.txt');

      try {
        // Escrever os dados recebidos no arquivo de logs
        await file.writeAsString('$data\n', mode: FileMode.append);
      } catch (e) {
        _logMessage('Erro ao salvar os dados no arquivo: $e');
      }
    }
  }

  bool _isCsvData(String data) {
    List<String> values = data.split(',');
    if (values.length >= 5) {
      return values.every((value) => double.tryParse(value) != null);
    }
    return false;
  }

  void _logMessage(String message) async {
    setState(() {
      logsController.text += '$message\n';
      logsController.selection =
          TextSelection.collapsed(offset: logsController.text.length);
    });

    
  }

  void _startSendingStatusCommand() {
    if (port != null && isPortOpen) {
      sendTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        _sendCommandWithText('status csv *');
      });
      setState(() {
        isPlaying = true;
        isLogging = true; 
      });
    } else {
      _logMessage('Port not open. Cannot start sending commands.');
    }
  }

  void _stopSendingStatusCommand() {
    sendTimer?.cancel();
    setState(() {
      isPlaying = false;
      isLogging = false;
    });
  }

  void _sendCommandWithText(String command) {
    if (port != null && isPortOpen) {
      if (isPdMode) {
        String fullCommand = "\x02" + command + "\x03";
        String bcc = _calculateBCC(fullCommand);
        String fullCommandWithBCC = fullCommand + bcc;

        if (commandMode == CommandMode.Hexadecimal) {
          List<int> bytes = _parseHexString(fullCommandWithBCC);
          port!.write(Uint8List.fromList(bytes));
          _logMessage(
              'Sent command in hexadecimal (pd mode): $fullCommandWithBCC');
        } else {
          port!.write(
              Uint8List.fromList(utf8.encode(fullCommandWithBCC + '\n')));
          _logMessage('Sent command in ASCII (pd mode): $fullCommandWithBCC');
        }
      } else {
        if (commandMode == CommandMode.Hexadecimal) {
          List<int> bytes = _parseHexString(command);
          port!.write(Uint8List.fromList(bytes));
          _logMessage('Sent command in hexadecimal: $command');
        } else {
          port!.write(Uint8List.fromList(utf8.encode(command + '\n')));
          _logMessage('Sent command in ASCII: $command');
        }
      }
    } else {
      _logMessage('Port not open. Cannot send command.');
    }
  }

  void _updateChartData(String data) {
    List<String> parts = data.split(';');
    if (parts.length >= 10) {
      setState(() {
        minData.add(ChartData(double.parse(parts[6])));
        midData.add(ChartData(double.parse(parts[7])));
        maxData.add(ChartData(double.parse(parts[8])));
        inMinData.add(ChartData(double.parse(parts[12])));
        inMidData.add(ChartData(double.parse(parts[13])));
        inMaxData.add(ChartData(double.parse(parts[14])));
      });

      if (minData.length > 50) {
        setState(() {
          minData.removeRange(0, minData.length - 50);
          midData.removeRange(0, midData.length - 50);
          maxData.removeRange(0, maxData.length - 50);
        });
      }

      double minValue = double.parse(parts[6]);
      double midValue = double.parse(parts[7]);
      double maxValue = double.parse(parts[8]);

      if (minValue > 0.0 || midValue > 0.0 || maxValue > 0.0) {
        _logMessage(
            'Threshold exceeded: Min=$minValue, Mid=$midValue, Max=$maxValue');
      }
    }
  }

Future<void> _downloadLogs() async {
    // Obter o diretório de downloads usando path_provider
    final downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory == null) {
      _logMessage('Erro ao obter o diretório de Downloads.');
      return;
    }

    // Criar o caminho completo do arquivo de logs
    final file = File('${downloadsDirectory.path}\\logs.txt');

    try {
      // Ler o conteúdo do arquivo de logs
      String logsText = await file.readAsString();
      
      // Exibir uma mensagem ou log informando sobre o download
      _logMessage('Logs baixados para ${file.path}');

      // TODO: Implementar a lógica para enviar o arquivo para o usuário ou processar conforme necessário
    } catch (e) {
      _logMessage('Erro ao ler o arquivo de logs: $e');
    }
  }

  @override
  void dispose() {
    _closePort();
    sendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SU Data Chart'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
        IconButton(
          icon: Icon(Icons.download),
          onPressed: () {
            _downloadLogs();
          },
        ),
      ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(children: [
              Expanded(
                child: SfCartesianChart(
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    alignment: ChartAlignment.near,
                  ),
                  primaryXAxis: NumericAxis(
                    visibleMinimum:
                        minData.isNotEmpty ? minData.last.timestamp - 10 : null,
                    visibleMaximum:
                        minData.isNotEmpty ? minData.last.timestamp : null,
                  ),
                  primaryYAxis: NumericAxis(
                    visibleMinimum: _calculateYMin(),
                    visibleMaximum: _calculateYMax(),
                  ),
                  series: <ChartSeries>[
                    LineSeries<ChartData, double>(
                      dataSource: minData,
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: 'Min Data',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                    SplineSeries<ChartData, double>(
                      splineType: SplineType.cardinal,
                      dataSource: midData,
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: 'Mid Data',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                    LineSeries<ChartData, double>(
                      dataSource: maxData,
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: 'Max Data',
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
                ),
              ),
              Expanded(
                child: SfCartesianChart(
                  legend: Legend(
                    isVisible: true,
                    position: LegendPosition.top,
                    alignment: ChartAlignment.near,
                  ),
                  primaryXAxis: NumericAxis(
                    visibleMinimum:
                        minData.isNotEmpty ? minData.last.timestamp - 10 : null,
                    visibleMaximum:
                        minData.isNotEmpty ? minData.last.timestamp : null,
                  ),
                  primaryYAxis: NumericAxis(
                    visibleMinimum: _calculateYMinIn(),
                    visibleMaximum: _calculateYMaxIn(),
                  ),
                  series: <ChartSeries>[
                    LineSeries<ChartData, double>(
                      dataSource: inMinData,
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: 'In Min Data',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                    SplineSeries<ChartData, double>(
                      dataSource: inMidData,
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: 'In Mid Data',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                    LineSeries<ChartData, double>(
                      dataSource: inMaxData,
                      xValueMapper: (ChartData data, _) => data.timestamp,
                      yValueMapper: (ChartData data, _) => data.value,
                      name: 'In Max Data',
                      markerSettings: MarkerSettings(isVisible: true),
                    ),
                  ],
                ),
              )
            ]),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 200,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: commandController,
                          decoration: InputDecoration(
                            labelText: 'Enter command to send',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _sendCommand,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (value) {
                            _sendCommand();
                          },
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: ScrollController(),
                            child: TextField(
                              controller: logsController,
                              maxLines: null,
                              enabled: false,
                              decoration: InputDecoration.collapsed(
                                hintText: 'Serial Logs',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Container(
                  width: 250,
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: selectedPort,
                            items: availablePorts.map((String port) {
                              return DropdownMenuItem<String>(
                                value: port,
                                child: Text(port),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedPort = value;
                              });
                            },
                          ),
                          SizedBox(width: 10),
                          Switch(
                            value: isPortOpen,
                            activeTrackColor: Colors.green,
                            inactiveTrackColor:
                                Color.fromARGB(255, 230, 62, 50),
                            inactiveThumbColor: Colors.white,
                            onChanged: (bool value) {
                              if (value) {
                                _openPort();
                              } else {
                                _closePort();
                              }
                              setState(() {
                                isPortOpen = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Text(
                        isPortOpen
                            ? '$selectedPort open'
                            : '$selectedPort close',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isPortOpen ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ASCII',
                            style: TextStyle(
                              fontWeight: commandMode == CommandMode.ASCII
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: commandMode == CommandMode.ASCII
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                          Switch(
                            value: commandMode == CommandMode.Hexadecimal,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              setState(() {
                                commandMode = value
                                    ? CommandMode.Hexadecimal
                                    : CommandMode.ASCII;
                              });
                            },
                          ),
                          Text(
                            'Hex',
                            style: TextStyle(
                              fontWeight: commandMode == CommandMode.Hexadecimal
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: commandMode == CommandMode.Hexadecimal
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Pause'),
                          Switch(
                            value: isPlaying,
                            activeColor: Colors.blue,
                            onChanged: (bool value) {
                              if (value) {
                                _startSendingStatusCommand();
                              } else {
                                _stopSendingStatusCommand();
                              }
                              setState(() {
                                isPlaying = value;
                              });
                            },
                          ),
                          Text('Play'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('CLI Mode'),
                          Switch(
                            value: isPdMode,
                            onChanged: (bool value) {
                              setState(() {
                                isPdMode = value;
                              });
                            },
                          ),
                          Text('PD Mode'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final double value;
  final double timestamp;

  ChartData(this.value)
      : timestamp = DateTime.now().millisecondsSinceEpoch / 1000.0;
}
