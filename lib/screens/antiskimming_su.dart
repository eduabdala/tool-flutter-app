import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'porta_com_antiskimming.dart';

class AntiskimmingSUTela extends StatelessWidget {
  const AntiskimmingSUTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Antiskimming-SU'),
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PortaCom()),
              );
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            child: const Text('Antiskimming-SU'),
          ),
        ),
      ),
    );
  }

void _executePythonFunctionSU(String funcao) async{
final shell = Shell();
 
    try{
      var result = await shell.run('python lib\\material\\test\\libraries\\commands.py $funcao');
      //ignore: avoid_print
      print(result.outText);
    } catch(e){
      //ignore: avoid_print
      print("erro ao executar o script python: $e");
}
  }
}
