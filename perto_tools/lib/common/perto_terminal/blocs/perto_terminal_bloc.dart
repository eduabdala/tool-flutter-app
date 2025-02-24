import '../../../core/services/serial_handler.dart';
import 'perto_terminal_event.dart';
import 'perto_terminal_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PertoTerminalBloc extends Bloc<PertoTerminalEvent, PertoTerminalState> {
  late SerialHandler _serialHandler; // Instância do SerialHandler

  PertoTerminalBloc() : super(PertoTerminalInitial()) {
    // Ouvintes para eventos específicos
    on<ListAvailablePortsEvent>(_onListAvailablePortsEvent);
    on<ConnectDeviceEvent>(_onConnectDeviceEvent);
    on<DesconnectDeviceEvent>(_onDesconnectDeviceEvent);
    on<SendDataEvent>(_onSendDataEvent);
    on<ReceiveDataEvent>(_onReceiveDataEvent);
  }

// Função para o evento ListAvailablePortsEvent
  Future<void> _onListAvailablePortsEvent(
      ListAvailablePortsEvent event, Emitter<PertoTerminalState> emit) async {
    emit(PertoTerminalLoading());
    try {
      // Listar as portas disponíveis usando SerialHandler
      List<String> availablePorts = SerialHandler.listAvailablePorts();
      
      // Emitir o estado com as portas disponíveis
      emit(PertoTerminalPortsAvailable(availablePorts));
    } catch (e) {
      emit(PertoTerminalError('Erro ao listar portas disponíveis'));
    }
  }

  // Função para o evento ConnectDeviceEvent
  Future<void> _onConnectDeviceEvent(
      ConnectDeviceEvent event, Emitter<PertoTerminalState> emit) async {
    emit(PertoTerminalLoading());
    try {
      // Cria a instância de SerialHandler e tenta abrir a conexão
      _serialHandler = SerialHandler(event.com, baudRate: event.baudRate);
      int result = _serialHandler.openConnection();
      if (result == 0) {
        emit(PertoTerminalConnected(event.com));
      } else {
        emit(PertoTerminalError('Erro ao conectar ao dispositivo'));
      }
    } catch (e) {
      emit(PertoTerminalError('Erro ao conectar dispositivo'));
    }
  }

  // Função para o evento DesconnectDeviceEvent
  Future<void> _onDesconnectDeviceEvent(
      DesconnectDeviceEvent event, Emitter<PertoTerminalState> emit) async {
    emit(PertoTerminalLoading());
    try {
      // Fecha a conexão do dispositivo
      _serialHandler.closeConnection();
      emit(PertoTerminalDisconnected(event.com));
    } catch (e) {
      emit(PertoTerminalError('Erro ao desconectar dispositivo'));
    }
  }

  // Função para o evento SendDataEvent
  Future<void> _onSendDataEvent(
      SendDataEvent event, Emitter<PertoTerminalState> emit) async {
    emit(PertoTerminalLoading());
    try {
      // Envia dados utilizando o protocolo PertoDireto
      String? response = await _serialHandler.sendDataPertoDireto(event.com);
      if (response != null) {
        emit(PertoTerminalDataSent(event.com));
      } else {
        emit(PertoTerminalError('Erro ao enviar dados'));
      }
    } catch (e) {
      emit(PertoTerminalError('Erro ao enviar dados'));
    }
  }

  // Função para o evento ReceiveDataEvent
  Future<void> _onReceiveDataEvent(
      ReceiveDataEvent event, Emitter<PertoTerminalState> emit) async {
    emit(PertoTerminalLoading());
    try {
      // Recebe dados utilizando o protocolo PertoDireto
      String? response = await _serialHandler.sendDataPertoDireto(event.com);
      if (response != null) {
        emit(PertoTerminalDataReceived(event.com, response));
      } else {
        emit(PertoTerminalError('Erro ao receber dados'));
      }
    } catch (e) {
      emit(PertoTerminalError('Erro ao receber dados'));
    }
  }
}
