import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<String> runPythonFunction(String scriptPath, String functionName, String arguments) async {
  String pythonScript = await rootBundle.loadString('lib/services/$scriptPath');
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = '${tempDir.path}/commands.py';
  File tempFile = File(tempPath);
  await tempFile.writeAsString(pythonScript);

  ProcessResult result = await Process.run('python', [tempPath, functionName, arguments]);
  
  if (result.exitCode == 0) {
    return result.stdout as String;
  } else {
    throw Exception(result.stderr);
  }

}
