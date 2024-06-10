import 'dart:io';

import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

class SerialConfig {
  String port;
  int baudRate;
  

  SerialConfig({
    required this.port,
    required this.baudRate,
  });
}

class SerialConfigScreen extends StatefulWidget {
  final Function(SerialConfig) onConfigSave;

  const SerialConfigScreen({super.key, required this.onConfigSave});

  @override
  _SerialConfigScreenState createState() => _SerialConfigScreenState();
}

class _SerialConfigScreenState extends State<SerialConfigScreen> {
  final TextEditingController baudRateController = TextEditingController(text: '115200');
  String selectedPort = '';
  List<String> availablePorts = [];

  @override
  void initState() {
    super.initState();
    _listAvailablePorts();
  }

  Future<void> _listAvailablePorts() async {
    try {
      // Execute the Python script
      ProcessResult result = await runExecutableArguments('python', ['lib//screens//list_ports.py']);
      
      // Split the output by new lines and filter out empty lines
      List<String> ports = result.stdout.toString().split('\n').where((port) => port.isNotEmpty).toList();
      
      // Update the state with the available ports
      setState(() {
        availablePorts = ports;
        if (availablePorts.isNotEmpty) {
          selectedPort = availablePorts[0];
        }
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Porta Serial'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedPort.isNotEmpty ? selectedPort : null,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPort = newValue!;
                });
              },
              items: availablePorts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: const Text('Selecione a Porta COM'),
            ),
            TextField(
              controller: baudRateController,
              decoration: const InputDecoration(labelText: 'Taxa de Transmissão'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(70, 50),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue
              ),
              onPressed: () {
                SerialConfig config = SerialConfig(
                  port: selectedPort,
                  baudRate: int.parse(baudRateController.text)
                );
                widget.onConfigSave(config);
                Navigator.pop(context);
              },
              child: const Text('Salvar Configuração'),
            ),
          ],
        ),
      ),
    );
  }
}