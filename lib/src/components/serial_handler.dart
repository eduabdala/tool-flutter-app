/***********************************************************************
 * $Id$        serial_handler.dart           2024-09-24
 *//**
 * @file        serial_handler.dart
 * @brief       Handler for serial port communication
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  SerialHandler Serial Communication Handler
/// @{
library;


import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_libserialport/flutter_libserialport.dart';

/// @brief A class for managing serial port communication
/// 
/// This class facilitates opening, closing, and sending commands through 
/// a serial port. It handles reading responses from the connected device.
class SerialHandler {
  final String port; ///< The name of the serial port
  SerialPort? ser; ///< Instance of the SerialPort
  int baudRate; ///< Baud rate for the serial connection

  /// @brief Constructor for SerialHandler
  /// 
  /// Initializes the serial port handler with the specified port and 
  /// optional baud rate.
  /// 
  /// @param port The name of the serial port to use
  /// @param baudRate The baud rate for the serial communication (default: 115200)
  SerialHandler(this.port, {this.baudRate = 115200});

  /// @brief Opens a connection to the serial port
  /// 
  /// This method attempts to open the serial port for read/write 
  /// operations and configures the baud rate.
  /// 
  /// @return int Returns 0 if successful, or 1 if there was an error
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

  /// @brief Closes the serial port connection
  /// 
  /// This method ensures that the serial port is properly closed 
  /// if it is currently open.
  void closeConnection() {
    if (ser != null && ser!.isOpen) {
      ser!.close();
    }
  }

  /// @brief Sends a command and waits for a response from the device
  /// 
  /// This method sends a command to the device connected via the 
  /// serial port and reads the response. It is designed for 
  /// graphical command communication.
  /// 
  /// @param command The command to send
  /// @return Future<String?> Returns the response from the device or null if no response
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

  /// @brief Sends a command and retrieves the immediate response
  /// 
  /// This method sends a command to the device and reads the 
  /// response. It is designed for terminal command communication.
  /// 
  /// @param command The command to send
  /// @return Future<String?> Returns the response from the device or null if no response
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
/** @} */
