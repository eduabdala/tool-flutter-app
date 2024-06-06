import 'package:flutter/material.dart';
import 'porta_com.dart';

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
