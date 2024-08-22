import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CsvLogger {
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/status_log.txt';
    return filePath;
  }

  Future<void> appendData(String data) async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    if (!await file.exists()) {
      await file.writeAsString('Timestamp, Data\n');
    }

    await file.writeAsString(data, mode: FileMode.append);
  }

  Future<String> getFilePath() async {
    return await _getFilePath();
  }
}