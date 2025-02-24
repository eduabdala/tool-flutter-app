import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/perto_terminal_bloc.dart';
import '../blocs/perto_terminal_event.dart';
import '../blocs/perto_terminal_state.dart';

class PertoTerminalPage extends StatefulWidget {
  const PertoTerminalPage({super.key});

  @override
  _PertoTerminalPageState createState() => _PertoTerminalPageState();
}

class _PertoTerminalPageState extends State<PertoTerminalPage> {
  String? _selectedPort;
  TextEditingController _sendController = TextEditingController();
  TextEditingController _baudRateController = TextEditingController(text: '115200');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perto Terminal'),
      ),
      body: BlocProvider(
        create: (context) => PertoTerminalBloc(),
        child: BlocBuilder<PertoTerminalBloc, PertoTerminalState>(
          builder: (context, state) {
            if (state is PertoTerminalLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is PertoTerminalInitial) {
              return buildInitial(context);
            } else if (state is PertoTerminalPortsAvailable) {
              return buildPortsList(context, state);
            } else if (state is PertoTerminalConnected) {
              return buildConnected(context, state);
            } else if (state is PertoTerminalDisconnected) {
              return buildDisconnected(context, state);
            } else if (state is PertoTerminalDataSent) {
              return buildDataSent(context, state);
            } else if (state is PertoTerminalDataReceived) {
              return buildDataReceived(context, state);
            } else if (state is PertoTerminalError) {
              return buildError(context, state);
            }
            return buildInitial(context); // Caso não esteja em nenhum estado específico
          },
        ),
      ),
    );
  }

  // Tela inicial com botões para listar portas e conectar/disconectar
  Widget buildInitial(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ListAvailablePortsEvent());
            },
            child: Text('Listar Portas Disponíveis'),
          ),
        ],
      ),
    );
  }

  // Tela para listar as portas disponíveis
  Widget buildPortsList(BuildContext context, PertoTerminalPortsAvailable state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Selecione uma porta:'),
          DropdownButton<String>(
            hint: Text('Selecione uma porta'),
            value: _selectedPort,
            items: state.ports.map((port) {
              return DropdownMenuItem<String>(
                value: port,
                child: Text(port),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPort = value;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _baudRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Baud Rate',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedPort != null) {
                context.read<PertoTerminalBloc>().add(
                  ConnectDeviceEvent(
                    _selectedPort!,
                    int.tryParse(_baudRateController.text) ?? 115200, // Usando o baud rate informado
                  ),
                );
              }
            },
            child: Text('Conectar ao Dispositivo'),
          ),
        ],
      ),
    );
  }

  // Tela quando o dispositivo está conectado
  Widget buildConnected(BuildContext context, PertoTerminalConnected state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Conectado à porta ${state.com}'),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _sendController,
              decoration: InputDecoration(
                labelText: 'Digite o comando',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_sendController.text.isNotEmpty) {
                context.read<PertoTerminalBloc>().add(SendDataEvent(state.com, int.tryParse(_baudRateController.text) ?? 115200, true));
              }
            },
            child: Text('Enviar Dados'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ReceiveDataEvent(state.com, int.tryParse(_baudRateController.text) ?? 115200, true));
            },
            child: Text('Receber Dados'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(DesconnectDeviceEvent(state.com));
            },
            child: Text('Desconectar'),
          ),
        ],
      ),
    );
  }

  // Tela quando o dispositivo está desconectado
  Widget buildDisconnected(BuildContext context, PertoTerminalDisconnected state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Desconectado da porta ${state.com}'),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ConnectDeviceEvent(state.com, 115200));
            },
            child: Text('Conectar novamente'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ListAvailablePortsEvent());
            },
            child: Text('Voltar para a Tela Inicial'),
          ),
        ],
      ),
    );
  }

  // Tela de dados enviados com sucesso
  Widget buildDataSent(BuildContext context, PertoTerminalDataSent state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Dados enviados com sucesso'),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ListAvailablePortsEvent());
            },
            child: Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(DesconnectDeviceEvent(state.com));
            },
            child: Text('Desconectar'),
          ),
        ],
      ),
    );
  }

  // Tela de dados recebidos
  Widget buildDataReceived(BuildContext context, PertoTerminalDataReceived state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Dados recebidos: ${state.data}'),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ListAvailablePortsEvent());
            },
            child: Text('Voltar'),
          ),
        ],
      ),
    );
  }

  // Tela de erro
  Widget buildError(BuildContext context, PertoTerminalError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Erro: ${state.message}', style: TextStyle(color: Colors.red)),
          ElevatedButton(
            onPressed: () {
              context.read<PertoTerminalBloc>().add(ListAvailablePortsEvent());
            },
            child: Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }
}
