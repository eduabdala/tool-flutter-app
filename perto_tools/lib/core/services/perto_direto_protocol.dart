// perto_direto_protocol.dart
import 'dart:convert';
import 'dart:typed_data';

/// Protocol handler to handle frame construction and response parsing
class ProtocolHandler {
  /// Builds a frame with start byte (0x02), command, end byte (0x03), and checksum (BCC)
  static Uint8List buildFrame(String command) {
    final List<int> frame = [0x02]; // Start Byte
    final commandBytes = utf8.encode(command);
    frame.addAll(commandBytes); // Add command bytes
    frame.add(0x03); // End Byte

    final bcc = calculateBCC(frame); // Calculate BCC (checksum)
    frame.add(bcc); // Add BCC to the frame

    return Uint8List.fromList(frame);
  }

  /// Calculates the BCC (checksum) for the frame using XOR operation
  static int calculateBCC(List<int> frame) {
    int bcc = 0;
    for (final byte in frame) {
      bcc ^= byte; // XOR operation for BCC
    }
    return bcc;
  }

  /// Parses the response, validating the start byte, end byte, and checksum (BCC)
  static String parseResponse(List<int> response) {
    if (response.isEmpty || response.first != 0x02 || response.last != 0x03) {
      return 'Invalid response'; // Check start and end byte
    }

    final data = response.sublist(1, response.length - 2); // Extract data (without delimiters)
    final expectedBCC = calculateBCC(response.sublist(0, response.length - 1)); // Verify BCC

    if (response[response.length - 2] != expectedBCC) {
      return 'Checksum error'; // Check BCC
    }

    return utf8.decode(data); // Decode the data and return
  }
}
