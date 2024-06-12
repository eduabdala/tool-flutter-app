import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

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
      throw Exception('A porta ja esta conectada.');
    }
  }

  void disconnect() {
    if (_serialPort != null) {
      _serialPort!.close();
      _serialPort = null;
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

  @override
  void initState() {
    super.initState();
    _selectedPort = SerialConnectionService().selectedPort;
    _getAvailablePorts();
  }

  void _getAvailablePorts() {
    final ports = SerialPort.availablePorts;
    setState(() {
      _ports = ports;
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectionService = SerialConnectionService();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedPort,
                  decoration: const InputDecoration(labelText: 'Porta Serial'),
                  items: _ports.map((port) {
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Selecione uma porta serial válida';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      connectionService.connect(_selectedPort!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Porta $_selectedPort conectada')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha ao conectar: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Conectar Porta COM'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  connectionService.disconnect();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Porta ${connectionService.selectedPort} desconectada')),
                  );
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
      ),
    );
  }
}
