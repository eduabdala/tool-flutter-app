import 'package:flutter/material.dart';
import 'porta_com_antiskimming.dart';

class AntiskimmingSUTela extends StatelessWidget {
  const AntiskimmingSUTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Antiskimming-SU'),
      ),
      body: Center(
        child: SizedBox(
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
        ),
      ),
    );
  }
}
