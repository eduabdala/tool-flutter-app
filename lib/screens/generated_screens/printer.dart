// lib/screens/generated_screens/printer.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '/services/python_service.dart';
import 'package:flutter_app/components/config_port.dart';


final TextEditingController _controllerPrinter = TextEditingController();

String textArg = _controllerPrinter.text; 

class Escp extends StatelessWidget {

  Escp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text('Impressora de recibos - ATM (ESC-P)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Center( child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:250,
                height:250,
                margin: const EdgeInsets.all(16.00),
                padding: const EdgeInsets.all(16.00),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
              child:TextField(
                controller: _controllerPrinter,
                decoration: const InputDecoration(border: InputBorder.none),
             ),
            ),
            
            const SizedBox(width: 10), 
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 15),
                ButtonComponent(component: ['/thermal_printer/commands.py', 'cortar',]),
                SizedBox(height: 16),
                ButtonComponent(component: ['/thermal_printer/commands.py', 'escrever',]),
                SizedBox(height: 16),
                ButtonComponent(component: ['/thermal_printer/commands.py', 'italico',]),
                SizedBox(height: 16),
                MenuConfig()
              ],
            ),
            SizedBox(width: 10,),
          ],
        )),
      ),
    );
  }
}


class ButtonComponent extends StatelessWidget {
  final List<String> component;

  const ButtonComponent({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        fixedSize: const Size(150, 50)
      ),
      onPressed: () {
        runPythonFunction(component[0],component[1], textArg);
      },
      child: Text(component[1]),
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
