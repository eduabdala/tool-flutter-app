import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialHandler {
  final String port;
  SerialPort? ser;
  int baudRate;

  SerialHandler(this.port, {this.baudRate = 115200});

  int openConnection() {
    try {
      ser = SerialPort(port);
      ser!.openReadWrite();
      ser!.config.baudRate = baudRate;
      return 0;
    } catch (e) {
      ser = null;
      return 1;
    }
  }

  void closeConnection() {
    if (ser != null && ser!.isOpen) {
      ser!.close();
    }
  }

  Future<String?> sendCommandGraph(String command) async {
    if (ser != null && ser!.isOpen) {
      ser!.write(Uint8List.fromList(utf8.encode(command)));
      await Future.delayed(Duration(milliseconds: 100));

      List<int> responseBytes = [];
      while (ser!.bytesAvailable > 0) {
        final response = ser!.read(ser!.bytesAvailable);
        if (response.isNotEmpty) {
          responseBytes.addAll(response);
        }
      }

      if (responseBytes.isNotEmpty) {
        ser!.flush();
        return utf8.decode(responseBytes);
      } else {
        return null;
      }
    }
    return null;
  }

  Future<String?> sendCommandTerminal(String command) async {
    if (ser != null && ser!.isOpen) {
      ser!.write(Uint8List.fromList(utf8.encode(command)));
      await Future.delayed(Duration(milliseconds: 500));
      final response = ser!.read(ser!.bytesAvailable);
      ser!.flush();
      return utf8.decode(response);
    }
    return null;
  }
}
