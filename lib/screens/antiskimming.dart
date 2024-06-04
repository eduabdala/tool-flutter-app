import 'package:flutter/material.dart';

class AntiskimmingScreen extends StatelessWidget {
  const AntiskimmingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antiskimming'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Ação para o botão Antiskimming-SU
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            child: const Text('Antiskimming-SU'),
          ),
        ),
      ),
    );
  }
}
