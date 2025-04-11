import 'package:flutter_tools/core/data/antiskimming_chart_data.dart';
import 'package:flutter_tools/core/services/parse_data_sensor.dart';
import 'package:flutter_tools/core/services/serial_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chart_data_event.dart';
import 'chart_data_state.dart';

class ChartDataBloc extends Bloc<ChartDataEvent, ChartDataState> {
  List<String> availablePorts = [];
  List<AntiskimmingChartData> chartData = [];
  String? connectedPort;
  late SerialHandler _serialHandler;



  ChartDataBloc() : super(ChartDataInitialState()) {
    on<GetAvailablePortsEvent>((event, emit) async {
      try {
        List<String> availablePorts = SerialHandler.listAvailablePorts();
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
              AntiskimmingChartData sensorDataResponse = parseAntiskimmingData(sensorResponse);
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
