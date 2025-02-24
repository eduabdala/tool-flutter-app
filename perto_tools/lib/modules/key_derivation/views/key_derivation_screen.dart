import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // Import necessário para manipulação de clipboard
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
                      onPressed: null, // Limpar os campos e disparar o evento de nova derivação
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
                          // Limpar os campos e disparar o evento de nova derivação
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
                    // Exibe a chave derivada
                    Text('Derived Key: ${model.derivedKey}'),
                    const SizedBox(height: 10),
                    // Exibe o KCV
                    Text('KCV: ${model.kcv}'),
                    const SizedBox(height: 20),
                    // Row para os botões de copiar chave derivada e KCV
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Copiar a chave derivada
                            Clipboard.setData(
                                ClipboardData(text: model.derivedKey));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Derived Key copied!')),
                            );
                          },
                          child: const Text('Copy Derived Key'),
                        ),
                        const SizedBox(width: 10), // Espaço entre os botões
                        ElevatedButton(
                          onPressed: () {
                            // Copiar o KCV
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
                    // Botão para nova derivação, centralizado abaixo dos botões de copiar
                    ElevatedButton(
                      onPressed: () {
                        // Limpar os campos e disparar o evento de nova derivação
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

            // Tela principal com os campos de entrada (aparece quando não há chave derivada)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row para os campos de entrada
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Column(
                      children: [
                        Container(
                          width: 300, // Definindo a largura
                          height: 60, // Definindo a altura
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
                        // Exibe a quantidade de caracteres e muda a cor
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
                          width: 300, // Definindo a largura
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
                        // Exibe a quantidade de caracteres e muda a cor
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

                  // Botões para alternar entre Hex e Dec e Derivar a chave
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: (_isHardwareIdValid && _isOriginalKeyValid)
                            ? () {
                                String hardwareId = _controller1.text;
                                String originalKey = _controller2.text;

                                // Envia o evento para o BLoC de derivação
                                context.read<KeyDerivationBloc>().add(
                                      DeriveKeyEvent(
                                        hardwareId: hardwareId,
                                        originalKey: originalKey,
                                      ),
                                    );
                              }
                            : null, // Botão desabilitado se a entrada for inválida
                        child: const Text('Derive Key'),
                      ),
                      const SizedBox(width: 10), // Espaço entre os botões

                      // Botão para alternar entre Hex e Dec
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
      // Se estiver no formato Hex, valida se a entrada é hexadecimal
      return RegExp(r'^[0-9A-Fa-f]*$').hasMatch(value);
    } else {
      // Se estiver no formato Decimal, valida se a entrada é numérica
      return RegExp(r'^\d*$').hasMatch(value);
    }
  }
}
