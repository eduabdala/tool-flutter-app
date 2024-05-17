import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'package:flython/flython.dart';
import 'dart:convert';
import 'dart:io';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Perto Printer'),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width:200,
                height:400,
                margin: const EdgeInsets.all(16.16),
                padding: const EdgeInsets.all(16.16),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Digite algo...',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16.0), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    chamarFuncaoPython('/home/eduardo/Git/PertoPrinter/perto_printer/lib/screens/teste.py', 'funcao');
                  },
                  child: const Text('Escrever'),
                ),
                const SizedBox(height: 16.0), 
                ElevatedButton(
                  onPressed: () {
                    chamarFuncaoPython('teste.py','funcao');
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
void chamarFuncaoPython(String nomeArquivo, String nomeFuncao) {
  Process.start('python3', [nomeArquivo]).then((Process process) {
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