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

  bool _isPortConnected(String port) {
    final serialPort = SerialPort(port);
    return serialPort.openReadWrite();
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
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
                  if (value == null || value.isEmpty || !_isPortConnected(value)) {
                    return 'Selecione uma porta serial válida';
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedPort = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Porta $_selectedPort selecionada e conectada')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Porta COM'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
