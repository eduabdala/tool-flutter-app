import 'package:flutter/material.dart';
import 'antiskimming_su.dart';
import 'protocolo_printer.dart';

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
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AntiskimmingScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Antiskimming'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AntiskimmingScreen extends StatelessWidget {
  const AntiskimmingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Antiskimming',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white), // Configura a cor da flecha para branca
      ),
      body: const Center(
        child: AntiskimmingSUButton(),
      ),
    );
  }
}
