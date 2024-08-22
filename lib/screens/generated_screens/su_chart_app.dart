import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/components/serial_handler.dart';
import 'package:flutter_app/components/custom_chart.dart';
import 'package:flutter_app/components/csv_logger.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

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
  SerialHandler? serialHandler;
  TextEditingController commandLineCLIController = TextEditingController();
  TextEditingController logWidgetController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  FocusNode logsFocusNode = FocusNode();
  int activeZones = 2;
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
  final CsvLogger _csvLogger = CsvLogger();

  @override
  void initState() {
    super.initState();
    _listAvailablePorts();
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
      serialHandler?.closeConnection();
      setState(() {
        isConnected = false;
        logWidgetController.text += 'Disconnected\n';
        firmwareVersion = "Unknown";
      });
    } else {
      if (selectedPort != null) {
        serialHandler = SerialHandler(selectedPort!);
        int result = serialHandler!.openConnection();
        if (result == 0) {
          setState(() {
            isConnected = true;
            logWidgetController.text += 'Connected to $selectedPort\n';
          });
          _getConfig();
          _getZone();
        } else {
          setState(() {
            logWidgetController.text += 'Failed to connect to $selectedPort\n';
          });
        }
      }
    }
  }

  void _downloadLogs() async {
    try {
      final filePath = await _csvLogger.getFilePath();
      final file = File(filePath);

      if (await file.exists()) {
        logWidgetController.text += "Log file created in: $filePath\n";
        // Exibe uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logs downloaded successfully!'),
          ),
        );
      } else {
        // Exibe uma mensagem de erro se o arquivo não existir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No log file found.'),
          ),
        );
      }
    } catch (e) {
      // Exibe uma mensagem de erro se algo der errado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading logs: $e'),
        ),
      );
    }
  }

  void _toggleGraph() {
    if (isRunning) {
      String command = 'status csv *\n';
      setState(() {
        flag = true;
        isRunning = false;
      });

      if (isConnected == false) {
        setState(() {
          logWidgetController.text += 'No connection established\n';
        });
        return;
      }

      sendTimer = Timer.periodic(Duration(milliseconds: timerInterval.toInt()),
          (timer) async {
        if (!isProcessingCommand) {
          try {
            String? response = await serialHandler?.sendCommandGraph(command);

            if (response != null && response.isNotEmpty) {
              _updateChartData(response);
              await _csvLogger.appendData(response);
            } else {
              setState(() {
                logWidgetController.text +=
                    'No response received or response is empty.\n';
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
      String commandAsn = "\x02" + commandLineCLIController.text + "\x03";
      String bcc = _calculateBCC(commandAsn);
      command = commandAsn + bcc;
    } else {
      command = commandLineCLIController.text + "\n";
    }

    setState(() {
      logWidgetController.text += 'Sending: $command\n';
    });

    setState(() {
      isProcessingCommand = true;
    });

    String? response = await serialHandler?.sendCommandTerminal(command);

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
    String commandAsn = "\x02" + "i" + "\x03";
    String bcc = _calculateBCC(commandAsn);
    String command = commandAsn + bcc;
    try {
      String? response = await serialHandler?.sendCommandTerminal(command);
      if (response != null) {
        setState(() {
          firmwareVersion = response.substring(3, 11);
        });
      } else {
        setState(() {
          logWidgetController.text += 'No response\n';
        });
      }
    } catch (e) {
      logWidgetController.text += 'Error: $e\n';
    }
  }

  Future<void> _getZone() async {
    String commandAsn = "\x02" + "S" + "\x03";
    String bcc = _calculateBCC(commandAsn);
    String command = commandAsn + bcc;
    try {
      String? response = await serialHandler?.sendCommandTerminal(command);
      if (response != null) {
        String zoneStatus = response.split('|')[0];
        int activeZones =
            zoneStatus.split('').where((char) => char == 'A').length;
        print(activeZones);
        setState(() {
          this.activeZones = activeZones;
        });
      } else {
        setState(() {
          logWidgetController.text += 'No response\n';
        });
      }
    } catch (e) {
      logWidgetController.text += 'Error: $e\n';
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
      int maxDataPoints = timeWindow.toInt();
      _trimExcessData(minData, maxDataPoints);
      _trimExcessData(midData, maxDataPoints);
      _trimExcessData(maxData, maxDataPoints);
      _trimExcessData(inMinData, maxDataPoints);
      _trimExcessData(inMidData, maxDataPoints);
      _trimExcessData(inMaxData, maxDataPoints);

      if (minData.length > 50) {
        setState(() {
          minData.removeRange(0, minData.length - 50);
          midData.removeRange(0, midData.length - 50);
          maxData.removeRange(0, maxData.length - 50);
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

  List<Widget> _generateChartWidgets() {
    List<Widget> chartWidgets = [];

    chartWidgets.add(
      Expanded(
        child: CustomChart(
          minData: minData,
          midData: midData,
          maxData: maxData,
          calculateYMin: _calculateYMin,
          calculateYMax: _calculateYMax,
          isPdMode: isPdMode,
        ),
      ),
    );

    if (activeZones > 1) {
      for (int i = 1; i < activeZones; i++) {
        chartWidgets.add(
          Expanded(
            child: CustomChart(
              minData: inMinData,
              midData: inMidData,
              maxData: inMaxData,
              calculateYMin: _calculateYMinIn,
              calculateYMax: _calculateYMaxIn,
              isPdMode: isPdMode,
            ),
          ),
        );
        if (i < activeZones - 1) {
          chartWidgets.add(SizedBox(width: 10));
        }
      }
    }
    return chartWidgets;
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearLogsField() {
    logWidgetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SU Data Chart - $firmwareVersion'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logs',
            icon: Icon(Icons.download),
            onPressed: () {
              _downloadLogs();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: _generateChartWidgets(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Select Port: "),
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
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConnected ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleConnection,
                  child: Text(isConnected ? "Connected" : "Disconnected"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleGraph,
                  child: Icon(
                    isRunning ? Icons.play_arrow : Icons.pause,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPdMode ? Colors.blue : Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleCmdMode,
                  child: Text(isPdMode ? "PD" : "CLI"),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Timer Interval (ms):"),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 200, // Ajuste o tamanho conforme necessário
                      child: Slider(
                        value: timerInterval,
                        min: 100.0,
                        max: 1000.0,
                        divisions: 9,
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
                SizedBox(width: 20), // Espaço entre sliders
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Time Window (samples):"),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 200, // Ajuste o tamanho conforme necessário
                    child: Slider(
                      value: timeWindow,
                      min: 10.0,
                      max: 100.0,
                      divisions: 9,
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
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: commandLineCLIController,
                    decoration: InputDecoration(
                      labelText: 'Enter command',
                    ),
                    onSubmitted: (value) {
                      if (value == "") {
                        logWidgetController.text += "Command not found\n";
                      } else {
                        if (value == 'clear') {
                        } else {
                          if (flag == true) {
                            executeCommand();
                            if (isProcessingCommand == false &&
                                isRunning == false) {
                              _toggleGraph();
                            }
                            print('0');
                          } else {
                            executeCommand();
                          }
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
                              _clearLogsField();
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
                            decoration: InputDecoration.collapsed(
                              hintText: 'Serial Logs',
                            ),
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'Courier',
                                fontSize: 14),
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
}
