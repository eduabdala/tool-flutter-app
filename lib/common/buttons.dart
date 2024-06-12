import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:flutter_app/common/config_port.dart';

final TextEditingController controller = TextEditingController();

class ButtonCmdPython extends StatelessWidget{
  const ButtonCmdPython({
    super.key,
    required this.label,
    required this.function,
    });

  final String label;
  final String function;
  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(70, 50),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue
        ),
        onPressed: (){
         _chamarFuncaoPython(function);
        },
      child: Text(label)
      ),
    );
  }
}

class TextBox extends StatelessWidget{
  const TextBox({super.key});
  @override 
  Widget build(BuildContext context){
    return Expanded(
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
            );
  }
}

class MenuConfig extends StatelessWidget{
  const MenuConfig({super.key});
  @override
  Widget build(BuildContext context){
    return SizedBox(
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
    );
  }
}


final Shell shell = Shell();
void _chamarFuncaoPython(String funcao) async{
  String xpto = controller.text;
  if(funcao == "escrever"){
    try{
      var result = await shell.run('python lib\\produtos\\thermalPrinter\\commands.py $funcao "$xpto"');
      //ignore: avoid_print
      print(result.outText);
    } catch(e){
      //ignore: avoid_print
      print("erro ao executar o script python: $e");
    }
  } else{
      try {
        var resulte = await shell.run('python lib\\produtos\\thermalPrinter\\commands.py  $funcao "$xpto"');
        //ignore: avoid_print
        print(resulte.outText);
      } catch (e) {
        //ignore: avoid_print
        print('erro ao executar o scrip python: $e');
      }
  }
}

void enviarTextoPrinter() async{
  String xpto = controller.text;
  if (xpto.isNotEmpty){
    try{
      var result = await shell.run('python lib\\produtos\\thermalPrinter\\commands.py escrever "$xpto"');
      //ignore:avoid_print
      print(result.outText);
    } catch (e){
      //ignore: avoid_print
      print('Erro ao executar o script python: $e');
    }
  }
}