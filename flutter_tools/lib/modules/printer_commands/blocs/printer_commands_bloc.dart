import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'printer_commands_event.dart';
import 'printer_commands_state.dart';

class CommandBloc extends Bloc<CommandEvent, CommandState> {
  CommandBloc() : super(CommandInitial()) {
    on<ExecuteCommand>(_onExecuteCommand);
    on<ResetCommandEvent>(_onResetCommandEvent);
  }

  Future<String> _copyExecutable() async {
    final directory = await getTemporaryDirectory();

    final execPath = '${directory.path}/thermal_printer_usb.exe';

    if (!(await File(execPath).exists())) {
      final ByteData data = await rootBundle.load('assets/app/thermal_printer_usb.exe');
      final buffer = data.buffer.asUint8List();
      await File(execPath).writeAsBytes(buffer);
    }

    return execPath;
  }

  Future<void> _onExecuteCommand(
      ExecuteCommand event, Emitter<CommandState> emit) async {
    emit(CommandLoading());

    try {
      final execPath = await _copyExecutable();

      List<String> commandArgs = [
        execPath,
        event.argument,
        event.command, 
      ];

      final process = await Process.start(
        commandArgs[0],
        commandArgs.sublist(1),
        mode: ProcessStartMode.normal,
      );

      String stderrResult = '';

      await for (var line in process.stderr.transform(utf8.decoder)) {
        stderrResult += line;
      }

      final exitCode = await process.exitCode;

      if (exitCode == 0) {
        emit(CommandInitial());
      } else {
        emit(CommandFailure(stderrResult.isNotEmpty ? stderrResult : 'Erro desconhecido')); 
      }

    } catch (e) {
      emit(CommandFailure(e.toString()));
    }
  }

  void _onResetCommandEvent(
      ResetCommandEvent event, Emitter<CommandState> emit) {
    emit(CommandInitial());
  }
}
