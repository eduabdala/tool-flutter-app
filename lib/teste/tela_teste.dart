import 'package:flutter/material.dart';
import 'package:perto_printer/screens/thermalPrinter/protocolo_printer.dart';
import 'package:process_run/process_run.dart';
import 'package:perto_printer/material/buttons.dart';
import 'package:perto_printer/material/config_port.dart';


final TextEditingController controller = TextEditingController();

class TelaTeste extends StatefulWidget{
  const TelaTeste({super.key});
  
  @override
  // ignore: library_private_types_in_public_api
  _TelaTeste createState() => _TelaTeste();
}

class _TelaTeste extends State<TelaTeste>  {
  final TextEditingController commandController = TextEditingController();
  
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
                        enviarTextoPrinter(); 
                      }, 
                      child: const Text('escrever'),
                    )
                ),
                const SizedBox(height: 16),
                const ButtonCmdPython(label: 'cortar', function: 'cortar'),
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
              ],
            ),
            const SizedBox(width: 10,)
          ],
        ),
      ),
    );
  }
}

void enviarTextoPrinter() async{
  String xpto = controller.text;
  if (xpto.isNotEmpty){
    try{
      var result = await shell.run('python lib\\screens\\commands.py escrever "$xpto"');
      //ignore:avoid_print
      print(result.outText);
    } catch (e){
      //ignore: avoid_print
      print('Erro ao executar o script python: $e');
    }
  }
}
