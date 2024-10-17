/***********************************************************************
 * $Id$        config_screen.dart              2024-09-24
 *//**
 * @file        config_screen.dart
 * @brief       Configuration screen for serial port settings
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  ConfigScreen Configuration Screen
/// @{
library;


import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_libserialport/flutter_libserialport.dart';

/// @brief A screen for configuring serial port settings
/// 
/// This screen allows users to select a serial port and specify the 
/// baud rate for communication. The configuration is saved to a JSON file.
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

/// @brief State class for ConfigScreen
/// 
/// This class manages the state and behavior of the ConfigScreen,
/// including port selection and configuration saving.
class _ConfigScreenState extends State<ConfigScreen> {
  final _formKey = GlobalKey<FormState>(); ///< Key for the form widget
  String? _selectedPort = ""; ///< Currently selected serial port
  String _baudRate = "115200"; ///< Default baud rate
  List<String> _ports = []; ///< List of available serial ports

  /// @brief Initializes the state and retrieves available ports
  @override
  void initState() {
    super.initState();
    _getPorts(); ///< Retrieves available serial ports on initialization
  }

  /// @brief Gets available serial ports and updates the state
  void _getPorts() {
    setState(() {
      _ports = SerialPort.availablePorts; ///< Fetches available serial ports
    });
  }

  /// @brief Gets the local path for saving configuration
  Future<String> get _localPath async {
    return Directory.current.path; ///< Returns the current directory path
  }

  /// @brief Gets the local file for serial configuration
  Future<File> get _localFile async {
    final path = await _localPath; ///< Retrieves the local path
    return File('$path/serial_config.json'); ///< Constructs the file path
  }

  /// @brief Writes the configuration to a JSON file
  /// 
  /// This method saves the provided configuration map to a JSON file.
  /// 
  /// @param config A map containing the configuration data
  Future<File> _writeConfig(Map<String, String?> config) async {
    final file = await _localFile; ///< Gets the local file
    return file.writeAsString(jsonEncode(config)); ///< Writes the configuration as JSON
  }

  /// @brief Saves the configuration when the form is valid
  /// 
  /// This method validates the form and saves the configuration to a file.
  void _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); ///< Saves the form state
      final config = {
        'port': _selectedPort,
        'baudRate': _baudRate,
      };
      await _writeConfig(config); ///< Writes the configuration to a file
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuração salva com sucesso!'))); ///< Shows success message
    }
  }

  /// @brief Builds the configuration screen widget
  /// 
  /// This method constructs the UI for the configuration screen, 
  /// including the form for selecting the serial port and baud rate.
  /// 
  /// @param context The BuildContext for the widget
  /// @return Widget The configuration screen widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração da Porta Serial'), ///< App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Porta Serial'), ///< Dropdown label
                items: _ports.map((port) {
                  return DropdownMenuItem<String>(
                    value: port,
                    child: Text(port),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPort = value; ///< Updates selected port
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione a porta serial'; ///< Validation message
                  }
                  return null;
                },
                onSaved: (value) {
                  _selectedPort = value; ///< Saves selected port
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Velocidade (baud rate)'), ///< Text field label
                keyboardType: TextInputType.number,
                initialValue: _baudRate, ///< Sets initial value
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecione a velocidade'; ///< Validation message
                  }
                  return null;
                },
                onSaved: (value) {
                  _baudRate = value!; ///< Saves baud rate
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveConfig, 
                child: const Text('Salvar Configuração') ///< Button label
              )
            ],
          ),
        )
      ),
    );
  }
}
/** @} */
