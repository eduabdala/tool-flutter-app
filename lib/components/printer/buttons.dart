import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';

class ButtonDefault extends StatelessWidget{
  const ButtonDefault({
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

final TextEditingController controller = TextEditingController();

final Shell shell = Shell();
void _chamarFuncaoPython(String funcao) async{
  String xpto = controller.text;
  if(xpto != "null"){
    try{
      var result = await shell.run('python lib\\screens\\commandsEscp.py $funcao "$xpto"');
      //ignore: avoid_print
      print(result.outText);
    } catch(e){
      //ignore: avoid_print
      print("erro ao executar o script python: $e");
    }
  } else{
      try {
        var resulte = await shell.run('python lib\\screens\\commandsEscp.py $funcao');
        //ignore: avoid_print
        print(resulte.outText);
      } catch (e) {
        //ignore: avoid_print
        print('erro ao executar o scrip python: $e');
      }
  }
}
