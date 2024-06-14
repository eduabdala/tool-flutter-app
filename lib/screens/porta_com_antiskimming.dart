import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:process_run/shell.dart';

class SerialConnectionService {
  static final SerialConnectionService _instance = SerialConnectionService._internal();
  SerialPort? _serialPort;
  String? _selectedPort;

  factory SerialConnectionService() {
    return _instance;
  }

  SerialConnectionService._internal();

  bool isConnected() => _serialPort?.isOpen ?? false;

  String? get selectedPort => _selectedPort;

  void connect(String port) {
    _selectedPort = port;
    _serialPort = SerialPort(port);
    if (!_serialPort!.openReadWrite()) {
      throw Exception('A porta já está conectada.');
    }
  }

  void disconnect() {
    if (_serialPort != null) {
      _serialPort!.close();
      _serialPort = null;
    }
  }

  Future<String> connectAuto() async {
    var shell = Shell();
    try {
      var result = await shell.run('python connect_auto.py');
      return result.outText.trim();  // trim to remove any extra whitespace
    } catch (e) {
      return 'Falha ao executar script Python: ${e.toString()}';
    }
  }
}

class PortaCom extends StatefulWidget {
  const PortaCom({super.key});

  @override
  _PortaComState createState() => _PortaComState();
}

class _PortaComState extends State<PortaCom> {
  final _formKey = GlobalKey<FormState>();
  List<String> _ports = [];
  String? _selectedPort;
  String _connectionStatus = '';

  @override
  void initState() {
    super.initState();
    _selectedPort = SerialConnectionService().selectedPort;
    _getAvailablePorts();
    _connectAutomatically();
  }

  void _getAvailablePorts() {
    final ports = SerialPort.availablePorts;
    setState(() {
      _ports = ports;
    });
  }

  Future<void> _connectAutomatically() async {
    final connectionService = SerialConnectionService();
    try {
      String result = await connectionService.connectAuto();
      setState(() {
        _connectionStatus = result.contains('Falha') ? 'Falha ao conectar automaticamente: $result' : 'Conectado automaticamente com sucesso.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_connectionStatus)),
      );
    } catch (e) {
      setState(() {
        _connectionStatus = 'Falha ao conectar automaticamente: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao conectar automaticamente: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Porta COM',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_connectionStatus.isNotEmpty)
              Text(
                _connectionStatus,
                style: TextStyle(color: Colors.green, fontSize: 16),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final connectionService = SerialConnectionService();
                connectionService.disconnect();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Porta ${connectionService.selectedPort} desconectada')),
                );
                setState(() {
                  _connectionStatus = 'Desconectado';
                });
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
              child: const Text('Desconectar Porta COM'),
            ),
          ],
        ),
      ),
    );
  }
}
