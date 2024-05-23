import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:perto_printer/screens/escp.dart';


class Protocoloprinter extends StatelessWidget{

  const Protocoloprinter({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'teste',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home:ScreenProtocolo(),
    );
  }
}

class ScreenProtocolo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Protocolo"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        body: Row( 
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Column(children: [
            ElevatedButton(
            onPressed:(){
            Navigator.push(
              context, MaterialPageRoute(builder: (context) 
              => const Escp())
              );
            }, 
          child: const Text('ESCP'),
          ),
          const SizedBox(height: 16.16),
          ElevatedButton(
            onPressed: (){
              Navigator.push(
                context, MaterialPageRoute(builder: (context)
                => const Escp())
              );
            },
            child: const Text('ESCPOS'),
          ),
          ]),
        ]),
      ),
    );
  }
}
  
