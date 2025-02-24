

import '../../../core/data/sensor_data.dart';

abstract class ChartDataState {}


class ChartDataInitialState extends ChartDataState {}

class ChartDataLoadingState extends ChartDataState {}

class ChartDataAvailablePortsState extends ChartDataState {
  final List<String> availablePorts;

  ChartDataAvailablePortsState(this.availablePorts);

  List<Object?> get props => [availablePorts];
}

class ChartDataConnectedState extends ChartDataState {
  final String com;
  
  ChartDataConnectedState(this.com);
}

class ChartDataDisconnectedState extends ChartDataState {
  final String com;

  ChartDataDisconnectedState(this.com);
}

class ChartDataReceivedState extends ChartDataState {
  final String data;

  ChartDataReceivedState(this.data);
}

class ChartDataRunningState extends ChartDataState {
  final SensorData data;

  ChartDataRunningState({
    required this.data,
  });
}

class ChartDataStopState extends ChartDataState {
}

class ChartDataErrorState extends ChartDataState {
  final String message;

  ChartDataErrorState(this.message);

  List<Object?> get props => [message];
}
