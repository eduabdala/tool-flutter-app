// printer_commands_event.dart

abstract class CommandEvent {}

class ExecuteCommand extends CommandEvent {
  final String command;
  final String argument;
  ExecuteCommand(this.command, this.argument);
}

class ResetCommandEvent extends CommandEvent {}

class FetchFirmwareVersionEvent extends CommandEvent {}
