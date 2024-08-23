import 'package:flutter/material.dart';
import 'package:flutter_app/services/python_service.dart';
import 'package:flutter_app/components/config_port.dart';
import 'package:flutter_app/components/theme_provider.dart';
import 'package:provider/provider.dart';

class Escp extends StatefulWidget {
  Escp({Key? key}) : super(key: key);

  @override
  _EscpState createState() => _EscpState();
}

class _EscpState extends State<Escp> {
  final TextEditingController _controllerPrinter = TextEditingController();
  late String arg;

  @override
  void initState() {
    super.initState();
    arg = '';
  }

  void _updateArg() {
    setState(() {
      arg = _controllerPrinter.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text('Impressora de recibos - ATM (ESC-P)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ]
        ),
        body: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTextInput(),
              const SizedBox(width: 10),
              _buildButtonColumn1(),
              const SizedBox(width: 10),
              _buildButtonColumn2(),
              const SizedBox(width: 10),
              _buildPreviewArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      width: 400,
      height: 400,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: _controllerPrinter,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (text) {
          _updateArg();
        },
      ),
    );
  }

  Widget _buildButtonColumn1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 15),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Cut', '']),
        const SizedBox(height: 16),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Print', arg]),
        const SizedBox(height: 16),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Italic', '']),
        const SizedBox(height: 16),
        ButtonComponent(component: ['thermal_printer/commands.py', 'QRCode', arg]),
        const SizedBox(height: 16),
        const MenuConfig()
      ],
    );
  }

  Widget _buildButtonColumn2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 15),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Bold', '']),
        const SizedBox(height: 16),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Expandido', arg]),
        const SizedBox(height: 16),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Condensado', '']),
        const SizedBox(height: 16),
        ButtonComponent(component: ['thermal_printer/commands.py', 'Normal', arg]),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      width: 370,
      height: 400,
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: SingleChildScrollView(
        child: Text(
          _formatPreview(arg),
          style: const TextStyle(fontFamily: 'Courier', fontSize: 12),
        ),
      ),
    );
  }

  String _formatPreview(String text) {
    const int maxColsNormal = 48;

    List<String> formattedLines = [];
    List<String> lines = text.split('\n');

    for (var line in lines) {
      while (line.length > maxColsNormal) {
        formattedLines.add(line.substring(0, maxColsNormal));
        line = line.substring(maxColsNormal);
      }
      formattedLines.add(line);
    }

    return formattedLines.join('\n');
  }
}

class ButtonComponent extends StatelessWidget {
  final List<String> component;

  const ButtonComponent({Key? key, required this.component}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        fixedSize: const Size(150, 50),
      ),
      onPressed: () {
        runPythonFunction(component[0], component[1], component[2]);
      },
      child: Text(component[1]),
    );
  }
}

class MenuConfig extends StatelessWidget {
  const MenuConfig({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(70, 50),
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfigScreen()));
        },
        child: const Text('Config'),
      ),
    );
  }
}
