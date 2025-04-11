import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/chart_data_bloc.dart';
import '../blocs/chart_data_event.dart';
import '../blocs/chart_data_state.dart';

class SuChartApp extends StatefulWidget {
  @override
  _SuChartAppState createState() => _SuChartAppState();
}

class _SuChartAppState extends State<SuChartApp> {
  bool isConnected = false;
  bool isRunning = false;
  bool isPdMode = true;
  double timerInterval = 1000.0; // Exemplo de valor inicial
  double timeWindow = 50.0; // Exemplo de valor inicial
  String selectedPort = '';
  List<String> availablePorts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SU Data Chart'),
        ),
        body: BlocProvider(
          create: (_) => ChartDataBloc(),
          child: BlocBuilder<ChartDataBloc, ChartDataState>(
              builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("COM: "),
                      BlocBuilder<ChartDataBloc, ChartDataState>(
                        builder: (context, state) {
                          if (state is ChartDataAvailablePortsState) {
                            return DropdownButton<String>(
                              value: selectedPort.isEmpty ? null : selectedPort,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedPort = value!;
                                });
                              },
                              items: state.availablePorts.map((port) {
                                return DropdownMenuItem<String>(
                                  value: port,
                                  child: Text(port),
                                );
                              }).toList(),
                            );
                          } else {
                            return Text('No ports available');
                          }
                        },
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context
                              .read<ChartDataBloc>()
                              .add(GetAvailablePortsEvent());
                        },
                        child: Icon(Icons.refresh),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isConnected ? Colors.green : Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (!isConnected) {
                            context.read<ChartDataBloc>().add(ConnectionEvent(
                                  selectedPort,
                                  115200,
                                ));
                            isConnected = true;
                          } else {
                            context
                                .read<ChartDataBloc>()
                                .add(DesconnectionEvent(selectedPort));
                                isConnected = false;
                          }
                        },
                        child: Text(isConnected ? "Connected to $selectedPort" : "Disconnected"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          isRunning = !isRunning;
                          if (isRunning) {
                            context.read<ChartDataBloc>().add(StartGraphEvent(
                                  true,
                                  'START_GRAPH_COMMAND',
                                ));
                          } else {
                            context
                                .read<ChartDataBloc>()
                                .add(StopGraphEvent(false, true));
                          }
                        },
                        child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPdMode ? Colors.blue : Colors.purpleAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          isPdMode = !isPdMode;
                          context
                              .read<ChartDataBloc>()
                              .add(ExecuteCommandEvent('TOGGLE_MODE'));
                        },
                        child: Text(isPdMode ? "PD" : "CLI"),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context.read<ChartDataBloc>().add(ClearChartEvent());
                        },
                        child: Icon(Icons.cleaning_services),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context
                              .read<ChartDataBloc>()
                              .add(DownloadLogsEvent());
                        },
                        child: Icon(Icons.build),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Timer Interval (ms):"),
                          SizedBox(height: 5),
                          Slider(
                            value: timerInterval,
                            min: 300.0,
                            max: 2000.0,
                            divisions: 17,
                            label: ' ms',
                            onChanged: (double value) {
                              setState(() {
                                timerInterval = value;
                              });
                              context
                                  .read<ChartDataBloc>()
                                  .add(UpdateTimerIntervalEvent(value));
                            },
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time Window (samples):"),
                            SizedBox(height: 5),
                            Slider(
                              value: timeWindow,
                              min: 20.0,
                              max: 100.0,
                              divisions: 8,
                              label: 'samples',
                              onChanged: (double value) {
                                setState(() {
                                  timeWindow = value;
                                });
                                context
                                    .read<ChartDataBloc>()
                                    .add(UpdateTimeWindowEvent(value));
                              },
                            ),
                          ]),
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
                          decoration: InputDecoration(
                            labelText: 'Enter command',
                          ),
                          onSubmitted: (String command) {
                            context
                                .read<ChartDataBloc>()
                                .add(ExecuteCommandEvent(command));
                          },
                        ),
                        Expanded(
                          child: Listener(
                            onPointerDown: (_) {},
                            child: Focus(
                              child: SingleChildScrollView(
                                child: TextField(
                                  maxLines: null,
                                  enabled: false,
                                  decoration: InputDecoration.collapsed(
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
            );
          }),
        ));
  }
}
