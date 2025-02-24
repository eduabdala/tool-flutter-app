// lib/bloc/command_state.dart
abstract class CommandState {}

class CommandInitial extends CommandState {}

class CommandLoading extends CommandState {}

class CommandSuccess extends CommandState {
  final String version;
  final String time;

  CommandSuccess(this.version, this.time);
}

class CommandFailure extends CommandState {
  final String error;

  CommandFailure(this.error);
}
