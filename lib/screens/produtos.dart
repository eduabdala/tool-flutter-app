import 'package:flutter/material.dart';
import 'package:perto_printer/screens/thermalPrinter/protocolo_printer.dart';
import 'package:perto_printer/components/antiskimming/buttons.dart';


class Produtos extends StatelessWidget {
  const Produtos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produtos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "Produtos",
          style: TextStyle(color: Colors.white),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProtocoloPrinter()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Impressora de Recibos - ATM'),
              ),
            ),
            const SizedBox(height: 20), // Espaço entre os botões
            const AntiskimmingSUButton()
          ],
        ),
      ),
    );
  }
}
