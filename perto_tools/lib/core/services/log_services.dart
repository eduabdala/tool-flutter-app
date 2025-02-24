import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class CsvLogger {
  // Função para obter o caminho do arquivo de log
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}\\status_log.txt';
    return filePath;
  }

  // Função para adicionar dados ao arquivo de log
  Future<void> appendData(String data) async {
    final filePath = await _getFilePath();
    final file = File(filePath);

    // Se o arquivo não existir, cria-o com um cabeçalho
    if (!await file.exists()) {
      await file.writeAsString('Timestamp, Data\n');
    }

    // Adiciona os dados ao arquivo
    await file.writeAsString(data, mode: FileMode.append);
  }

  // Função para obter o caminho do arquivo de log
  Future<String> getFilePath() async {
    return await _getFilePath();
  }

  // Função para verificar se o arquivo de log existe
  Future<bool> checkIfLogExists() async {
    final filePath = await _getFilePath();
    final file = File(filePath);
    return await file.exists();
  }

  // Função para "baixar" ou mostrar o status do arquivo de log
  void _downloadLogs(BuildContext context, TextEditingController logWidgetController) async {
    try {
      final fileExists = await checkIfLogExists();

      if (fileExists) {
        final filePath = await getFilePath();
        logWidgetController.text += "Log file created in: $filePath\n";
        
        // Exibe uma mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logs downloaded successfully!'),
          ),
        );
      } else {
        // Exibe uma mensagem de erro se o arquivo não existir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No log file found.'),
          ),
        );
      }
    } catch (e) {
      // Exibe uma mensagem de erro se algo der errado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading logs: $e'),
        ),
      );
    }
  }
}
