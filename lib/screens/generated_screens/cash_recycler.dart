// lib/screens/generated_screens/cash_recycler.dart
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CashRecycler(),
    );
  }
}

class CashRecycler extends StatefulWidget {
  @override
  _CashRecyclerState createState() => _CashRecyclerState();
}

class _CashRecyclerState extends State<CashRecycler> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _outputController1 = TextEditingController();
  final TextEditingController _outputController2 = TextEditingController();

  Future<void> _sendData() async {
    String pythonScriptPath = 'lib/services/cashRecycler/commands.py';

    ProcessResult result = await Process.run(
        'python', [pythonScriptPath, _controller1.text, _controller2.text]);

    if (result.exitCode == 0) {
      final outputPy = result.stdout;
      final parts = outputPy.split(' ');
      final arg1 = parts[0];
      final arg2 = parts[1];
      setState(() {
        _outputController1.text = arg1;
        _outputController2.text = arg2;
      });
    } else {
      throw Exception(result.stderr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Key Derivation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250,
              child: TextField(
                controller: _controller1,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Hardware ID'),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 250,
              child: TextField(
                controller: _controller2,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Original key'),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(180, 40),
                ),
                onPressed: _sendData,
                child: const Text('send')),
            const SizedBox(height: 15),
            Container(
              width: 250,
              child: TextField(
                controller: _outputController1,
                readOnly: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Derived Key'),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 250,
              child: TextField(
                controller: _outputController2,
                readOnly: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'KCV'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
