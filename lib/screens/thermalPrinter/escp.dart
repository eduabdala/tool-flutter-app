// ignore: file_names
import 'package:flutter/material.dart';
import 'package:perto_printer/material/buttons.dart';

final TextEditingController controller = TextEditingController();

class Escp extends StatelessWidget {
  
  const Escp({super.key});
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
        body: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextBox(),
            SizedBox(width: 10), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 15),
                ButtonCmdPython(label: 'Escrever', function: 'escrever'),
                SizedBox(height: 16),
                ButtonCmdPython(label: 'Cortar', function: 'cortar'),
                SizedBox(height: 16),
                MenuConfig(),
                SizedBox(height: 16),
              ],
            ),
            SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }
}
