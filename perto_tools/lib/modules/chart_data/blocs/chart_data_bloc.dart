import 'package:perto_tools/core/services/serial_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/sensor_data.dart';
import 'chart_data_event.dart';
import 'chart_data_state.dart';

class ChartDataBloc extends Bloc<ChartDataEvent, ChartDataState> {
  List<String> availablePorts = [];
  String? connectedPort;
  late SerialHandler _serialHandler;

  SensorData parseSensorData(String input) {
    List<String> parts = input.split(';');
    String data = parts[1];
    String hora = parts[2];
    List<Map<String, dynamic>> sensors = [];
    int i = 3; // Começamos após a data e hora

    while (i < parts.length) {
      if (i + 5 < parts.length) {
        String type = parts[i];
        String zone = parts[i + 1];
        String status = parts[i + 2];
        
        String minValue = parts[i + 3];
        String value = parts[i + 4];
        String maxValue = parts[i + 5];

        sensors.add({
          'type': type,
          'zone': zone,
          'status': status,
          'min_value': minValue,
          'value': value,
          'max_value': maxValue,
        });

        i += 6;
      } else {
        break;
      }
    }

    return SensorData(data: data, hora: hora, sensors: sensors);
  }

  ChartDataBloc() : super(ChartDataInitialState()) {
    on<GetAvailablePortsEvent>((event, emit) async {
      try {
        List<String> availablePorts = await SerialHandler.listAvailablePorts();
        emit(ChartDataAvailablePortsState(availablePorts));
      } catch (e) {
        emit(ChartDataErrorState('Error to list ports: $e'));
      }
    });

    on<ConnectionEvent>((event, emit) async {
      try {
        _serialHandler = SerialHandler(event.com, baudRate: event.baudRate);
        int result = _serialHandler.openConnection();
        if (result == 0) {
          emit(ChartDataConnectedState(event.com));
        } else {
          emit(ChartDataErrorState('Error to connect'));
        }
      } catch (e) {
        emit(ChartDataErrorState('Erro: $e'));
      }
    });

    on<DesconnectionEvent>((event, emit) async {
      try {
        _serialHandler.closeConnection();
        emit(ChartDataDisconnectedState(event.com));
      } catch (e) {
        emit(ChartDataErrorState('error: $e'));
      }
    });

    on<GetDeviceConfigEvent>((event, emit) async {
      try {
        String? response =
            await _serialHandler.sendDataPertoDireto(event.command);
        if (response != null) {
          emit(ChartDataReceivedState(response));
        } else {
          emit(ChartDataErrorState('Error to get device config.'));
        }
      } catch (e) {
        emit(ChartDataErrorState('error: $e'));
      }
    });

    on<StartGraphEvent>((event, emit) async {
      while (event.running) {
        try {
          String? sensorResponse = await _serialHandler.sendData(event.command);
          if (sensorResponse != null) {
            try {
              SensorData sensorDataResponse = parseSensorData(sensorResponse);
              emit(ChartDataRunningState(data: sensorDataResponse));
            } catch (e) {
              emit(ChartDataErrorState('error'));
            }
          }
        } catch (e) {
          emit(ChartDataErrorState(''));
        }
      }
    });

    on<StopGraphEvent>((event, emit) async {
      if (event.running && event.stop) {
        event.running == false;
        emit(ChartDataStopState());
      }
    });

    on<ExecuteCommandEvent>((event, emit) async {
      if (state is ChartDataConnectedState) {
        if (state is ChartDataRunningState) {
          try {
            emit(ChartDataStopState());
            String? response = await _serialHandler.sendData(event.command);

            if (response != null) {
              emit(ChartDataReceivedState(
                  response));
              emit(ChartDataRunningState(
                  data: (state as ChartDataRunningState).data));
            } else {
              emit(ChartDataErrorState('Error in receiving response.'));
            }
          } catch (e) {
            emit(ChartDataErrorState('Error executing command: $e'));
          }
        } else {
          try {
            String? response = await _serialHandler.sendData(event.command);

            if (response != null) {
              emit(ChartDataReceivedState(
                  response));
            } else {
              emit(ChartDataErrorState('Error in receiving response.'));
            }
          } catch (e) {
            emit(ChartDataErrorState('Error executing command: $e'));
          }
        }
      } else {
        emit(ChartDataErrorState('Device is not connected.'));
      }
    });

    on<UpdateTimeWindowEvent>((event, emit) async {});

    on<UpdateTimerIntervalEvent>((event, emit) async {});

    on<DownloadLogsEvent>((event, emit) async {});

    on<ClearChartEvent>((event, emit) async {});

    on<LoadGraphEvent>((event, emit) async {});
  }
}
