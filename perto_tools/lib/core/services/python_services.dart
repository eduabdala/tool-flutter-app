import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class PythonService {
  final String scriptsFolderPath;

  PythonService({this.scriptsFolderPath = 'lib/services/'});

  /// Executa uma função Python de um script especificado
  /// 
  /// [scriptPath] - Caminho do script Python no diretório de assets
  /// [functionName] - Nome da função Python a ser executada
  /// [arguments] - Argumentos a serem passados para a função Python
  Future<String> runPythonFunction(String scriptPath, String functionName, String arguments) async {
    try {
      String pythonScript = await rootBundle.loadString('$scriptsFolderPath$scriptPath');

      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/commands.py';
      File tempFile = File(tempPath);
      
      await tempFile.writeAsString(pythonScript);
      
      ProcessResult result = await Process.run('python', [tempPath, functionName, arguments]);
      
      if (result.exitCode == 0) {
        return result.stdout as String;
      } else {
        throw Exception('Erro ao executar script Python: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Falha ao executar o script Python: $e');
    }
  }
}
