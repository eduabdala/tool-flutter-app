import '../models/key_derivation_model.dart';

abstract class KeyDerivationState {}

class KeyDerivationInitial extends KeyDerivationState {}

class KeyDerivationLoadingState extends KeyDerivationState {
  // Este estado é usado quando a derivação da chave está em progresso
}

class KeyDerivationSuccess extends KeyDerivationState {
  final String derivedKey;
  final String kcv;

  KeyDerivationSuccess(this.derivedKey, this.kcv);
}

class KeyDerivationErrorState extends KeyDerivationState {
  final String errorMessage;

  KeyDerivationErrorState(this.errorMessage);
}

class KeyDerivationLoadedState extends KeyDerivationState {
  final KeyDerivationModel model;

  KeyDerivationLoadedState(this.model);
}
