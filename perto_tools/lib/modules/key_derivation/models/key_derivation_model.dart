class KeyDerivationModel {
  final String originalKey;
  final String hardwareId;
  final String derivedKey;
  final String kcv;

  KeyDerivationModel(this.hardwareId, this.originalKey, this.derivedKey, this.kcv);
}
