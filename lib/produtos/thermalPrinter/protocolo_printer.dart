import 'package:flutter/material.dart';
import 'package:flutter_app/produtos/thermalPrinter/escpos.dart';
import 'package:flutter_app/produtos/produtos.dart';
import 'package:flutter_app/produtos/thermalPrinter/escp.dart';


class ProtocoloPrinter extends StatelessWidget{

  const ProtocoloPrinter({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'protocolo',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home:const ScreenProtocolo(),
    );
  }
}

class ScreenProtocolo extends StatelessWidget{
  const ScreenProtocolo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text("Protocolo"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Produtos()));
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
              onPressed:(){
              Navigator.push(
                context, MaterialPageRoute(builder: (context) 
                => const Escp())
                );
              }, 
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
              ),
              child: const Text('ESCP'),
            ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              height: 50,
              child:ElevatedButton(
                onPressed: (){
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context)
                    => const Escpos())
                  );
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blue
                  ),
                child: const Text('ESCPOS'),
               )
            ),
            const SizedBox(height: 16),
          ]),
        )
      )
    );
  }
}
  
