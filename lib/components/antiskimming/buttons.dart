import 'package:flutter/material.dart';
import 'package:perto_printer/screens/antiskimming_su.dart';

// Primeira tela

class AntiskimmingSUButton extends StatelessWidget {
  const AntiskimmingSUButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AntiskimmingSUTela()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
        child: const Text('Antiskimming'),
      ),
    );
  }
}

class TestButton extends StatelessWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // Ação a ser realizada quando o botão "Teste" for pressionado
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.green,
        ),
        child: const Text('Teste'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AntiskimmingSUButton(),
            SizedBox(height: 20), // Espaçamento entre os botões
            TestButton(),
          ],
        ),
      ),
    );
  }
}
