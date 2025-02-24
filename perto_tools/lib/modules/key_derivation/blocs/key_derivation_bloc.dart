import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto; // Alias para a biblioteca crypto
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convert/convert.dart'; // Para conversão de hexadecimal
import 'package:pointycastle/api.dart' as pointycastle; // Alias para a biblioteca pointycastle
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import '../models/key_derivation_model.dart';
import 'key_derivation_event.dart';
import 'key_derivation_state.dart';

class KeyDerivationBloc extends Bloc<KeyDerivationEvent, KeyDerivationState> {
  KeyDerivationBloc() : super(KeyDerivationInitial()) {
    on<DeriveKeyEvent>((event, emit) async {
      // Define o estado de loading
      emit(KeyDerivationLoadingState());

      try {
        String hexHwId = _convertToHex(event.hardwareId);
        String hashedSerial = _convertAndHash(hexHwId);
        Uint8List derivedKeyBytes = _derivateKey(event.originalKey, hashedSerial);
        String derivedKey = hex.encode(derivedKeyBytes);
        String kcv = _calculateKCV(derivedKey);

        // Emite o estado com os dados da chave derivada
        emit(KeyDerivationLoadedState(KeyDerivationModel(event.hardwareId, event.originalKey, derivedKey, kcv)));
      } catch (e) {
        // Em caso de erro, emite um estado de erro
        emit(KeyDerivationErrorState("Erro na derivação de chave: $e"));
      }
    });

    // Para lidar com o evento de reset da derivação de chave
    on<ResetKeyDerivationEvent>((event, emit) {
      emit(KeyDerivationInitial());
    });
  }

  // Métodos auxiliares conforme o código que você forneceu

  String _convertAndHash(String hexSerialNumber) {
    String decimalSerialNumber = BigInt.parse(hexSerialNumber, radix: 16).toString();
    String paddedSerialNumber = decimalSerialNumber.padLeft(20, '0');
    String asciiValue = utf8.encode(paddedSerialNumber).map((e) => e.toRadixString(16)).join();
    List<int> bytes = asciiValue.codeUnits;
    crypto.Digest sha256Hash = crypto.sha256.convert(bytes);
    return sha256Hash.toString();
  }

  Uint8List _derivateKey(String key, String data) {
    final iv = Uint8List(16);
    final keyBytes = Uint8List.fromList(hex.decode(key));
    final dataBytes = Uint8List.fromList(hex.decode(data));

    final params = pointycastle.ParametersWithIV<pointycastle.KeyParameter>(pointycastle.KeyParameter(keyBytes), iv);
    final cipher = CBCBlockCipher(AESEngine())..init(true, params);

    final encryptedData = Uint8List(dataBytes.length);
    int offset = 0;
    while (offset < dataBytes.length) {
      offset += cipher.processBlock(dataBytes, offset, encryptedData, offset);
    }

    return encryptedData;
  }

  String _calculateKCV(String key) {
    final iv = Uint8List(16);
    final zeroBlock = Uint8List(16);
    final keyBytes = Uint8List.fromList(hex.decode(key));

    final params = pointycastle.ParametersWithIV<pointycastle.KeyParameter>(pointycastle.KeyParameter(keyBytes), iv);
    final cipher = CBCBlockCipher(AESEngine())..init(true, params);

    final encryptedKCV = Uint8List(zeroBlock.length);
    int offset = 0;
    while (offset < zeroBlock.length) {
      offset += cipher.processBlock(zeroBlock, offset, encryptedKCV, offset);
    }

    return encryptedKCV.sublist(0, 3).map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  String _convertToHex(String value) {
    return BigInt.parse(value).toRadixString(16).toUpperCase().padLeft(8, '0');
  }
}
