abstract class KeyDerivationEvent {}

class ConvertAndHashEvent extends KeyDerivationEvent {
  final String hexSerialNumber;

  ConvertAndHashEvent({required this.hexSerialNumber});
}

class DerivateKeyEvent extends KeyDerivationEvent {
  final String key;
  final String data;

  DerivateKeyEvent({required this.key, required this.data});
}

class CalculateKCVEvent extends KeyDerivationEvent {
  final String key;

  CalculateKCVEvent({required this.key});
}

class SendDataEvent extends KeyDerivationEvent {
  final String hardwareId;
  final String originalKey;

  SendDataEvent({required this.hardwareId, required this.originalKey});
}

class ConvertValueEvent extends KeyDerivationEvent {
  final String value;

  ConvertValueEvent({required this.value});
}

class DeriveKeyEvent extends KeyDerivationEvent {
  final String hardwareId;
  final String originalKey;

  DeriveKeyEvent({required this.hardwareId, required this.originalKey});
}

class ResetKeyDerivationEvent extends KeyDerivationEvent {}
