import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class PythonService {
  // Path para os scripts Python no diretório de assets
  final String scriptsFolderPath;

  PythonService({this.scriptsFolderPath = 'lib/services/'});

  /// Executa uma função Python de um script especificado
  /// 
  /// [scriptPath] - Caminho do script Python no diretório de assets
  /// [functionName] - Nome da função Python a ser executada
  /// [arguments] - Argumentos a serem passados para a função Python
  Future<String> runPythonFunction(String scriptPath, String functionName, String arguments) async {
    try {
      // Carrega o conteúdo do script Python a partir dos assets
      String pythonScript = await rootBundle.loadString('$scriptsFolderPath$scriptPath');
      
      // Obtém o diretório temporário para o arquivo
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = '${tempDir.path}/commands.py'; // Caminho temporário do script Python
      File tempFile = File(tempPath);
      
      // Escreve o script Python em um arquivo temporário
      await tempFile.writeAsString(pythonScript);
      
      // Executa o script Python com a função e os argumentos fornecidos
      ProcessResult result = await Process.run('python', [tempPath, functionName, arguments]);
      
      // Verifica se o script foi executado com sucesso
      if (result.exitCode == 0) {
        return result.stdout as String; // Retorna a saída padrão se for bem-sucedido
      } else {
        throw Exception('Erro ao executar script Python: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Falha ao executar o script Python: $e');
    }
  }
}
