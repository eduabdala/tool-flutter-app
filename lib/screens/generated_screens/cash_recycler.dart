import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, LengthLimitingTextInputFormatter, TextInputFormatter, rootBundle;
import 'package:path_provider/path_provider.dart';
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

  bool validateController1(String value) {
    if (value.isEmpty) return false;
    return int.tryParse(value) != null;
  }

  bool validateController2(String value) {
    return value.length == 64;
  }

  Future<void> _sendData() async {
    try {
      String pythonScript = await rootBundle.loadString('lib/services/cashRecycler/commands.py');
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/commands.py';
      File tempFile = File(tempPath);
      await tempFile.writeAsString(pythonScript);

      ProcessResult result = await Process.run(
          'python', [tempPath, _controller1.text, _controller2.text]);

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
    } catch (e) {
      print('Error running Python script: $e');
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250,
                child: TextField(
                  controller: _controller1,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(64), 
                    HexadecimalDecimalInputFormatter(), 
                  ],
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: validateController1(_controller1.text) ? Colors.green : Colors.red,
                      ),
                    ),
                    labelText: 'Hardware ID(Decimal)',
                    helperText: validateController1(_controller1.text)
                        ? null
                        : 'Insufficient or invalid characters.',
                    helperStyle: TextStyle(
                      color: validateController1(_controller1.text) ? Colors.green : Colors.red,
                    ),
                    suffixText: '${_controller1.text.length}',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 250,
                child: TextField(
                  controller: _controller2,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(64),
                    HexadecimalDecimalInputFormatter(), 
                  ],
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: validateController2(_controller2.text) ? Colors.green : Colors.red,
                      ),
                    ),
                    labelText: 'Original key',
                    helperText: _controller2.text.length == 64
                        ? null
                        : 'Insufficient or invalid characters.',
                    helperStyle: TextStyle(
                      color: _controller2.text.length == 64 ? Colors.green : Colors.red,
                    ),
                    suffixText: '${_controller2.text.length}',
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(180, 40),
                ),
                onPressed: validateController2(_controller2.text) ? _sendData : null,
                child: const Text('Send'),
              ),
              const SizedBox(height: 15),
              Container(
                width: 250,
                child: TextField(
                  controller: _outputController1,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Derived Key',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _outputController1.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Derived Key copied to clipboard')),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 250,
                child: TextField(
                  controller: _outputController2,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'KCV',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _outputController2.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('KCV copied to clipboard')),
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HexadecimalDecimalInputFormatter extends TextInputFormatter {
  final RegExp _hexDecRegex = RegExp(r'^[0-9A-Fa-f]*$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (_hexDecRegex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
