import 'dart:convert';
import 'dart:typed_data';
import 'serial_protocol.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class SerialHandler {
  final String port;
  SerialPort? ser;
  int baudRate;

  SerialHandler(this.port, {this.baudRate = 115200});

  static List<String> listAvailablePorts() {
    return SerialPort.availablePorts;
  }

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

  Future<String?> sendData(String command) async {
    if (ser != null && ser!.isOpen) {
      ser!.write(Uint8List.fromList(utf8.encode(command)));
      await Future.delayed(Duration(milliseconds: 500));
      final response = ser!.read(ser!.bytesAvailable);
      ser!.flush();
      return utf8.decode(response);
    }
    return null;
  }

  Future<String?> sendDataPertoDireto(String command) async {
    if (ser != null && ser!.isOpen) {
      final frame = ProtocolHandler.buildFrame(command);

      ser!.write(frame);

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
        return ProtocolHandler.parseResponse(responseBytes);
      } else {
        return 'No response received';
      }
    }
    return 'Serial port not open';
  }
}
