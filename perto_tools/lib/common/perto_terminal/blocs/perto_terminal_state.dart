abstract class PertoTerminalState {}

class PertoTerminalInitial extends PertoTerminalState {}

class PertoTerminalLoading extends PertoTerminalState {}

class PertoTerminalConnected extends PertoTerminalState {
  final String com;

  PertoTerminalConnected(this.com);
}

class PertoTerminalDisconnected extends PertoTerminalState {
  final String com;

  PertoTerminalDisconnected(this.com);
}

class PertoTerminalError extends PertoTerminalState {
  final String message;

  PertoTerminalError(this.message);
}

class PertoTerminalDataSent extends PertoTerminalState {
  final String com;


  PertoTerminalDataSent(this.com);
}

class PertoTerminalDataReceived extends PertoTerminalState {
  final String com;
  final String data;

  PertoTerminalDataReceived(this.com, this.data);
}

class PertoTerminalPortsAvailable extends PertoTerminalState {
  final List<String> ports;

  PertoTerminalPortsAvailable(this.ports);
}

