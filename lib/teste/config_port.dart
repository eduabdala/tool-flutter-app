import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:path_provider/path_provider.dart';

class ConfigScreen extends StatefulWidget{
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedPort = "";
  String _baudRate = "115200";
  List<String> _ports = [];

  @override
  void initState(){
    super.initState();
    _getPorts();
  }

  void _getPorts(){
    setState(() {
      _ports = SerialPort.availablePorts;
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
   final path = await _localPath;
   return File('$path/serial_config.json');
 }
 Future<File> _writeConfig(Map<String, String?> config) async {
   final file = await _localFile;
   return file.writeAsString(jsonEncode(config));
 }
 void _saveConfig() async {
   if (_formKey.currentState!.validate()) {
     _formKey.currentState!.save();
     final config = {
       'port': _selectedPort,
       'baudRate': _baudRate,
     };
     await _writeConfig(config);
     ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Configuração salva com sucesso!')));
   }
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('config porta serial'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children:<Widget> [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Porta Serial'),
                items: _ports.map((port) {
                  return DropdownMenuItem<String>(
                    value: port,
                    child: Text(port),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPort = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty){
                    return 'Selecione a porta serial';
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedPort = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: ('velocidade (baud rate)')),
                keyboardType: TextInputType.number,
                initialValue: _baudRate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione a velocidade';
                  }
                  return null;
                },
                onSaved: (value) {
                  _baudRate = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _saveConfig, child: Text('Salvar Configuração'))
            ],
          ),
        )
      ),
    );
  }
  void _asaveConfig() async {
  if(_formKey.currentState!.validate()) {
    _formKey.currentState!.save();
  
    final config = {
      'port': _selectedPort,
      'baudRate': _baudRate,
    };

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('serialConfig', jsonEncode(config));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Configuração Salva")));
    
    }
  }
}

