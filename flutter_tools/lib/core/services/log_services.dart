import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class CsvLogger {

  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}\\status_log.txt';
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

  Future<bool> checkIfLogExists() async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    return await file.exists();
  }

  void _downloadLogs(BuildContext context, TextEditingController logWidgetController) async {
    try {
      final fileExists = await checkIfLogExists();

      if (fileExists) {
        final filePath = await getFilePath();
        logWidgetController.text += "Log file created in: $filePath\n";

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logs downloaded successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No log file found.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading logs: $e'),
        ),
      );
    }
  }
}
