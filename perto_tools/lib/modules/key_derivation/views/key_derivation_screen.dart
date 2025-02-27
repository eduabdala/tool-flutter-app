import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../blocs/key_derivation_bloc.dart';
import '../blocs/key_derivation_event.dart';
import '../blocs/key_derivation_state.dart';
import '../models/key_derivation_model.dart';

class KeyDerivationScreen extends StatefulWidget {
  const KeyDerivationScreen({super.key});

  @override
  _KeyDerivationScreenState createState() => _KeyDerivationScreenState();
}

class _KeyDerivationScreenState extends State<KeyDerivationScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();

  bool _isHardwareIdValid = true;
  bool _isOriginalKeyValid = true;
  bool _isHexFormat = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Key Derivation'),
      ),
      body: BlocProvider(
        create: (_) => KeyDerivationBloc(),
        child: BlocBuilder<KeyDerivationBloc, KeyDerivationState>(
          builder: (context, state) {
            if (state is KeyDerivationLoadingState) {
              return const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: null,
                      child: Text('New Derivation'),
                    ),
                  ],
                ),
              );
            } else if (state is KeyDerivationErrorState) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Text('Error: ${state.errorMessage}'),
                    ElevatedButton(
                        onPressed: () {
                          _controller1.clear();
                          _controller2.clear();
                          context
                              .read<KeyDerivationBloc>()
                              .add(ResetKeyDerivationEvent());
                        },
                        child: const Text('New Derivation'))
                  ]));
            } else if (state is KeyDerivationLoadedState) {
              KeyDerivationModel model = state.model;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Derived Key: ${model.derivedKey}'),
                    const SizedBox(height: 10),
                    Text('KCV: ${model.kcv}'),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: model.derivedKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Derived Key copied!')),
                            );
                          },
                          child: const Text('Copy Derived Key'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: model.kcv));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('KCV copied!')),
                            );
                          },
                          child: const Text('Copy KCV'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _controller1.clear();
                        _controller2.clear();
                        context
                            .read<KeyDerivationBloc>()
                            .add(ResetKeyDerivationEvent());
                      },
                      child: const Text('New Derivation'),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      children: [
                        Container(
                          width: 300,
                          height: 60,
                          child: TextField(
                            controller: _controller1,
                            decoration: InputDecoration(
                              labelText: 'Hardware ID',
                              border: OutlineInputBorder(),
                              errorText: !_isHardwareIdValid &&
                                      _controller1.text.isNotEmpty
                                  ? 'Invalid Format'
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isHardwareIdValid = _isValidInput(value);
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          '${_controller1.text.length} caracteres',
                          style: TextStyle(
                            color:
                                _isHardwareIdValid ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      children: [
                        Container(
                          width: 300,
                          height: 60,
                          child: TextField(
                            controller: _controller2,
                            decoration: InputDecoration(
                              labelText: 'Original Key',
                              border: OutlineInputBorder(),
                              errorText: !_isOriginalKeyValid &&
                                      _controller2.text.isNotEmpty
                                  ? 'Invalid Format'
                                  : null,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isOriginalKeyValid = _isValidInput(value);
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          '${_controller2.text.length} caracteres',
                          style: TextStyle(
                            color:
                                _isOriginalKeyValid ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (_isHardwareIdValid && _isOriginalKeyValid)
                            ? () {
                                String hardwareId = _controller1.text;
                                String originalKey = _controller2.text;
                                context.read<KeyDerivationBloc>().add(
                                      DeriveKeyEvent(
                                        hardwareId: hardwareId,
                                        originalKey: originalKey,
                                      ),
                                    );
                              }
                            : null,
                        child: const Text('Derive Key'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isHexFormat = !_isHexFormat;
                          });
                        },
                        child: Text(_isHexFormat
                            ? 'Switch to Decimal'
                            : 'Switch to Hex'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isValidInput(String value) {
    if (_isHexFormat) {
      return RegExp(r'^[0-9A-Fa-f]*$').hasMatch(value);
    } else {
      return RegExp(r'^\d*$').hasMatch(value);
    }
  }
}
