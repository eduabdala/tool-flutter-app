import 'package:flutter/material.dart';
import 'package:perto_printer/screens/protocolo_printer.dart';
//import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
//import 'package:flython/flython.dart';
import 'dart:convert';
import 'dart:io';
import 'package:process_run/process_run.dart';
import 'package:perto_printer/components/printer/buttons.dart';
import 'package:perto_printer/teste/config_port.dart';

class SerialConfig {
  String port;

  

  SerialConfig({
    required this.port,

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
          print(ports);
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
                );
                widget.onConfigSave(config);
                Navigator.pop(context);
                print(selectedPort);
              },
              child: const Text('Salvar Configuração'),
            ),
          ],
        ),
      ),
    );
  }
}

final TextEditingController controller = TextEditingController();

class TelaTeste extends StatefulWidget{
  const TelaTeste({super.key});
  
  @override
  _TelaTeste createState() => _TelaTeste();
}

class _TelaTeste extends State<TelaTeste>  {
  final TextEditingController commandController = TextEditingController();
  SerialConfig? serialConfig;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text('Impressora de recibos - teste'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context, MaterialPageRoute(builder: (context) => const ProtocoloPrinter()));
            },
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width:200,
                height:400,
                margin: const EdgeInsets.all(16.00),
                padding: const EdgeInsets.all(16.00),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Digite algo...',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 15),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50),
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.blue
                      
                    ),
                    onPressed: () {
                      _chamarFuncaoPython(serialConfig!, 'cortar', '');

                      },
                    child: const Text('cortar'),
                  ),
                ),
                const SizedBox(height: 16),
                const ButtonCmdPython(label: '...', function: 'cortar'),
                const SizedBox(height: 16),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50),
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.blue
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigScreen()));
                    },
                    child: const Text('Config'),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(70, 50),
                      foregroundColor: Colors.white, 
                      backgroundColor: Colors.blue
                    ),
                    onPressed: () {
                      Navigator.push(
                       context,
                      MaterialPageRoute(
                        builder: (context) => SerialConfigScreen(
                          onConfigSave: (config) {
                            setState(() {
                              serialConfig = config;
                            });
                          },
                        ),
                      ),
                    );
                      },
                    child: const Text('COM'),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10,)
          ],
        ),
      ),
    );
  }
}


void sendCommandToPrinter(SerialConfig config, String command) async {
  try {
    var result = await shell.runExecutableArguments('python', ['lib/screens/printer_script.py', config.port,command]);
    print('Output: ${result.stdout}');
    print('Error: ${result.stderr}');
  } catch (e) {
    print('Error: $e');
  }
}


void chamarFuncaoPythonWeb(xpto) async{
  
  try {
      var response = await http.post(
        Uri.parse('http://127.0.0.1:5000/chamar_funcao'),
        body: {'funcao': xpto},      );
      if (response.statusCode == 200) {
        //ignore: avoid_print
        print('funcionou');
      } else {
        //ignore: avoid_print
        print('Erro ao chamar a função: ${response.statusCode}');
      }
    } catch (e) {
      //ignore: avoid_print
      print('Erro: $e');
    }
  }




final Shell shell = Shell();
void _chamarFuncaoPython(SerialConfig config, String funcao, String xpto) async{
  String xpto = controller.text;
  String port = config.port;
  if(xpto != "null"){
    try{
      var result = await shell.run('python lib\\screens\\commandsEscp.py $funcao "teste" $port');
      //ignore: avoid_print
      print(result.outText);
    } catch(e){
      //ignore: avoid_print
      print("erro ao executar o script python: $e");
    }
  } else{
      try {
        var resulte = await shell.run('python lib\\screens\\commandsEscp.py $port $funcao "$xpto"');
        //ignore: avoid_print
        print(resulte.outText);
      } catch (e) {
        //ignore: avoid_print
        print('erro ao executar o scrip python: $e');
      }
  }
}

void configSerial(String com, int baud) {

}

@override
void dispose(){
  controller.dispose();
  dispose();
}

void enviarTextoPrinter() async{
  String xpto = controller.text;
  String commandsPath = 'lib\\screens';
  if (xpto.isNotEmpty){
    try{
      ProcessResult result = await Process.run('python', ['$commandsPath\\commandsEscp.py escrever "$xpto"']);
      //var result = await shell.run('python commands.py funcao1 $xpto');
      //ignore: avoid_print
      print('output: ${result.stdout}');
      //ignore:avoid_print
      print('error: ${result.stderr}');
      //ignore:avoid_print
      print(result.outText);
    } catch (e){
      //ignore: avoid_print
      print('Erro ao executar o script python: $e');
    }
  }
}

void chamarFuncaoPython(String nomeArquivo, String nomeFuncao) {
  Process.start('python', [nomeArquivo]).then((Process process) {
    process.stdin.writeln(nomeFuncao);
    process.stdin.close();
    process.stdout.transform(utf8.decoder).listen((data) {
      //ignore:avoid_print
      print(data);
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      //ignore:avoid_print
      print('Erro: $data');
    });
  }).catchError((error) {
    //ignore:avoid_print
    print('Erro ao iniciar o processo Python: $error');
  });
}