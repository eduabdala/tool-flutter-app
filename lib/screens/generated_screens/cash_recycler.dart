import 'package:flutter/material.dart';
import '/../services/python_service.dart';

class CashRecycler extends StatelessWidget{
  const CashRecycler({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Key Derivation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed:() {runPythonFunction("\\cashRecycler\\commands.py", "derivKey", '');},
          child: const Text('data')
        ),
      ),
    );
  }
} 