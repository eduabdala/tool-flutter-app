abstract class ChartDataEvent {}

class ConnectionEvent extends ChartDataEvent {
  final String com;
  final int baudRate;

  ConnectionEvent(this.com, this.baudRate);
}

class DesconnectionEvent extends ChartDataEvent {
  final String com;

  DesconnectionEvent(this.com);
}

class GetDeviceConfigEvent extends ChartDataEvent {
  final String command;

  GetDeviceConfigEvent(this.command);
}

class StartGraphEvent extends ChartDataEvent {
  final bool running;
  final String command;

  StartGraphEvent(this.running, this.command);
}

class StopGraphEvent extends ChartDataEvent {
  final bool running;
  final bool stop;

  StopGraphEvent(this.running, this.stop);
}

class GetAvailablePortsEvent extends ChartDataEvent {}

class ChartDataPortsAvailableEvent extends ChartDataEvent {}

class ClearChartEvent extends ChartDataEvent {}

class LoadGraphEvent extends ChartDataEvent {}

class ExecuteCommandEvent extends ChartDataEvent {
  final String command;
  ExecuteCommandEvent(this.command);
}

class ReceiveDataEvent extends ChartDataEvent {}

class UpdateChartDataEvent extends ChartDataEvent {}

class UpdateTimerIntervalEvent extends ChartDataEvent {
  final double interval;
  UpdateTimerIntervalEvent(this.interval);
}

class UpdateTimeWindowEvent extends ChartDataEvent {
  final double windowSize;
  UpdateTimeWindowEvent(this.windowSize);
}

class DownloadLogsEvent extends ChartDataEvent {}
