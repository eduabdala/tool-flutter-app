abstract class PertoTerminalEvent {}

class ListAvailablePortsEvent extends PertoTerminalEvent {}

class ConnectDeviceEvent extends PertoTerminalEvent {
  final String com;
  final int baudRate;

  ConnectDeviceEvent(this.com, this.baudRate);
}

class DesconnectDeviceEvent extends PertoTerminalEvent {
  final String com;

  DesconnectDeviceEvent(this.com);
}

class SendDataEvent extends PertoTerminalEvent {
  final String com;
  final int baudRate;
  final bool pertoDiretoProtocol;

  SendDataEvent(this.com, this.baudRate, this.pertoDiretoProtocol);
}

class ReceiveDataEvent extends PertoTerminalEvent {
  final String com;
  final int baudRate;
  final bool pertoDiretoProtocol;

  ReceiveDataEvent(this.com, this.baudRate, this.pertoDiretoProtocol);
}

