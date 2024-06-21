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
  }

  void _getAvailablePorts() {
    final ports = SerialPort.availablePorts;
    setState(() {
      _ports = ports;
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _executePythonFunctionSU("pipeline_serial_port");
                      _executePythonFunctionSU("calibrate_sensors");
                      // Ação do botão "Calibrar"
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Calibrar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Outros widgets ou botões aqui, se necessário
          ],
        ),
      ),
    );
  }
  void _executePythonFunctionSU(String funcao) async{
final shell = Shell();
 
    try{
      var result = await shell.run('python lib\\material\\test\\libraries\\commands.py $funcao');
      print(result.outText);
    } catch(e){
      print("erro ao executar o script python: $e");
    }
  }
}
