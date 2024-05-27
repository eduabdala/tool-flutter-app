import 'package:flutter/material.dart';
import 'package:perto_printer/screens/protocolo_printer.dart';
//import 'package:flutter/widgets.dart';
//import 'package:http/http.dart' as http;
//import 'package:flython/flython.dart';
import 'dart:convert';
import 'dart:io';
import 'package:process_run/process_run.dart';

final TextEditingController controller = TextEditingController();

class Escpos extends StatelessWidget {
  
  const Escpos({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text('Impressora de recibos - ATM (ESC-POS)'),
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Digite algo...',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.16), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(70, 50),
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    enviarTextoPrinter();
                    },
                  child: const Text('Escrever'),
                  
                ),
                const SizedBox(height: 16.16), 
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(70, 50),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue
                  ),
                  onPressed: () {
                    _chamarFuncaoPython('funcao2', 'none');
                  },
                  child: const Text('Cortar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*
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
*/

final Shell shell = Shell();
void _chamarFuncaoPython(String funcao, String arg2) async{

  try {
    var result = await shell.run('python lib\\screens\\commands.py $funcao $arg2');
    //ignore: avoid_print
    print(result.outText);
  } catch (e) {
    //ignore: avoid_print
    print('erro ao executar o scrip python: $e');
  }
}

@override
void dispose(){
  controller.dispose();
  dispose();
}

void enviarTextoPrinter() async{
  String xpto = controller.text;
  if (xpto.isNotEmpty){
    try{
      ProcessResult result = await Process.run('sh', ['-c', 'python commandsEscp.py funcao1 $xpto']);
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