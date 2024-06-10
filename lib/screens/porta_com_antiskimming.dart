import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class PortaCom extends StatefulWidget {
  const PortaCom({super.key});

  @override
  _PortaComState createState() => _PortaComState();
}

class _PortaComState extends State<PortaCom> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPort;
  List<String> _ports = [];
  SerialPort? _serialPort;

  @override
  void initState() {
    super.initState();
    _getAvailablePorts();
  }

  void _getAvailablePorts() {
    final ports = SerialPort.availablePorts;
    setState(() {
      _ports = ports;
    });
  }

  Future<bool> _isPortConnected(String port) async {
    _serialPort = SerialPort(port);
    return _serialPort!.openReadWrite();
  }

  void _disconnectPort() {
    if (_serialPort != null) {
      _serialPort!.close();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Porta $_selectedPort desconectada')),
      );
    }
  }

  Future<void> _handleButtonPress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool isConnected = await _isPortConnected(_selectedPort!);
      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Porta $_selectedPort selecionada e conectada')),
        );
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao conectar a porta $_selectedPort')),
        );
      }
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 200,  // Define a largura da caixa de seleção
                child: DropdownButtonFormField<String>(
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
                  onSaved: (value) {
                    _selectedPort = value;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleButtonPress,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Conectar Porta COM'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _disconnectPort,
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
