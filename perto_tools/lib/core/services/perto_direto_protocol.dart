import 'dart:convert';
import 'dart:typed_data';

class ProtocolHandler {
  static Uint8List buildFrame(String command) {
    final List<int> frame = [0x02];
    final commandBytes = utf8.encode(command);
    frame.addAll(commandBytes);
    frame.add(0x03);

    final bcc = calculateBCC(frame);
    frame.add(bcc);

    return Uint8List.fromList(frame);
  }

  static int calculateBCC(List<int> frame) {
    int bcc = 0;
    for (final byte in frame) {
      bcc ^= byte;
    }
    return bcc;
  }

  static String parseResponse(List<int> response) {
    if (response.isEmpty || response.first != 0x02 || response.last != 0x03) {
      return 'Invalid response';
    }

    final data = response.sublist(1, response.length - 2);
    final expectedBCC = calculateBCC(response.sublist(0, response.length - 1));

    if (response[response.length - 2] != expectedBCC) {
      return 'Checksum error';
    }

    return utf8.decode(data);
  }
}
