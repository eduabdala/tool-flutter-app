import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perto_printer/screens/protocoloPrinter.dart';


class Produtos extends StatelessWidget{

  const Produtos({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'teste',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home:FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Produtos"),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed:(){
            Navigator.push(
              context, MaterialPageRoute(builder: (context) 
              => const Protocoloprinter())
              );
            }, 
          child: const Text('Impressora de Recibos - ATM'),
          ),
        ),
      ),
    );
  }
}
  
