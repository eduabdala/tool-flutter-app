import 'package:flutter/material.dart';
import 'porta_com_antiskimming.dart';

// Tela ajustada com AppBar azul e botão padronizado
class AntiskimmingSUTela extends StatelessWidget {
  const AntiskimmingSUTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Antiskimming-SU',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,  // Cor azul na AppBar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: AntiskimmingSUButton(),
      ),
    );
  }
}

// Botão padrão para navegação
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
            MaterialPageRoute(builder: (context) => const PortaCom()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
        child: const Text('Antiskimming-SU'),
      ),
    );
  }
}