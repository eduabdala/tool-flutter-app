import 'package:flutter/material.dart';
import 'package:flutter_app/services/python_service.dart';
import 'package:flutter_app/components/config_port.dart';

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
    return MaterialApp(
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
        ),
        body: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
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
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 15),
                  ButtonComponent(component: ['thermal_printer/commands.py', 'cortar', '']),
                  const SizedBox(height: 16),
                  ButtonComponent(component: ['thermal_printer/commands.py', 'escrever', arg]), 
                  const SizedBox(height: 16),
                  ButtonComponent(component: ['thermal_printer/commands.py', 'italico', '']),
                  const SizedBox(height: 16),
                  ButtonComponent(component: ['thermal_printer/commands.py', 'QRCode', arg]),
                  const SizedBox(height: 16),
                  const MenuConfig()
                ],
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
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
