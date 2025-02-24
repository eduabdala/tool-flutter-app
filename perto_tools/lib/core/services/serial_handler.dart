// serial_handler.dart
import 'dart:convert';
import 'dart:typed_data';
import 'perto_direto_protocol.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';


class SerialHandler {
  final String port; ///< The name of the serial port
  SerialPort? ser; ///< Instance of the SerialPort
  int baudRate; ///< Baud rate for the serial connection

  /// Constructor for SerialHandler
  SerialHandler(this.port, {this.baudRate = 115200});

  /// List available serial ports
  static List<String> listAvailablePorts() {
    return SerialPort.availablePorts;
  }

  /// Opens a connection to the serial port
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

  /// Closes the serial port connection
  void closeConnection() {
    if (ser != null && ser!.isOpen) {
      ser!.close();
    }
  }

  /// Sends a command and retrieves the immediate response
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

  /// Send command using protocol (start byte, end byte, and BCC)
  Future<String?> sendDataPertoDireto(String command) async {
    if (ser != null && ser!.isOpen) {
      // Build frame using protocol (start byte 0x02, end byte 0x03)
      final frame = ProtocolHandler.buildFrame(command);

      // Send the frame to the serial port
      ser!.write(frame);

      await Future.delayed(Duration(milliseconds: 100)); // Wait for response

      List<int> responseBytes = [];
      while (ser!.bytesAvailable > 0) {
        final response = ser!.read(ser!.bytesAvailable);
        if (response.isNotEmpty) {
          responseBytes.addAll(response);
        }
      }

      // Parse the response
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
