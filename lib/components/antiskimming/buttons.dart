import 'package:flutter/material.dart';
import 'package:perto_printer/screens/antiskimming_su.dart';


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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AntiskimmingSUButton(),
            SizedBox(height: 20),
            TestButton(),
          ],
        ),
      ),
    );
  }
}
