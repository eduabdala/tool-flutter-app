import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/printer_commands_bloc.dart';
import '../blocs/printer_commands_event.dart';
import '../blocs/printer_commands_state.dart';

class CommandScreen extends StatefulWidget {
  const CommandScreen({super.key});

  @override
  _CommandScreenState createState() => _CommandScreenState();
}

class _CommandScreenState extends State<CommandScreen> {
  final TextEditingController _commandController = TextEditingController();
  bool _isCommandValid = false;
  bool _isAsciiMode = true;

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer USB'),
      ),
      body: BlocProvider(
        create: (_) => CommandBloc(),
        child: BlocBuilder<CommandBloc, CommandState>(
          builder: (context, state) {
            if (state is CommandLoading) {
              return const Center(
                child: 
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue,),
                    
                    Text('Sending command...')
                  ]
                  )
              );
            } else if (state is CommandSuccess) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Version: ${state.version}'),
                    Text('Time: ${state.time}'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _commandController.clear();
                        context.read<CommandBloc>().add(ResetCommandEvent());
                      },
                      child: const Text('New Command'),
                    ),
                  ],
                ),
              );
            } else if (state is CommandFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.error}'),
                    ElevatedButton(
                      onPressed: () {
                        _commandController.clear();
                        context.read<CommandBloc>().add(ResetCommandEvent());
                      },
                      child: const Text('Return'),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            width: 450,
                            constraints: const BoxConstraints(
                              maxHeight: 200,
                            ),
                            child: TextField(
                              controller: _commandController,
                              decoration: InputDecoration(
                                labelText: 'Enter Command',
                                border: const OutlineInputBorder(),
                                errorText: !_isCommandValid &&
                                        _commandController.text.isNotEmpty
                                    ? 'Invalid Command'
                                    : null,
                              ),
                              maxLines: null,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                setState(() {
                                  _isCommandValid = _isValidCommand(value);
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_commandController.text.length} characters',
                          style: TextStyle(
                            color: _isCommandValid ? Colors.green : Colors.red,
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
                        onPressed: _isCommandValid
                            ? () {
                                String command = _commandController.text;
                                String argument =
                                    _isAsciiMode ? '-a' : '-x';

                                context.read<CommandBloc>().add(
                                      ExecuteCommand(command, argument),
                                    );
                              }
                            : null,
                        child: const Text('Print Text'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _isCommandValid
                            ? () {
                                String command = _commandController.text;
                                String argument =
                                    _isAsciiMode ? '--ascii' : '--hex';

                                context.read<CommandBloc>().add(
                                      ExecuteCommand(command, argument),
                                    );
                                context.read<CommandBloc>().add(
                                      ExecuteCommand('1b77', '-x'),
                                    );
                              }
                            : null,
                        child: const Text('Print & Cut'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed:(){
                                String command = '1b77';
                                String argument = '--hex';
                                context.read<CommandBloc>().add(
                                      ExecuteCommand(command, argument),
                                    );
                              },
                            
                        child: const Text('Cut'),
                      ),
                      const SizedBox(width: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isAsciiMode = !_isAsciiMode;
                              });
                            },
                            child: Text(_isAsciiMode ? "ASCII" : "HEX"),
                          ),
                        ],
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

  bool _isValidCommand(String value) {
    // Aqui você pode implementar a validação do comando, se necessário
    return value.isNotEmpty;
  }
}
