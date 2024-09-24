/***********************************************************************
 * $Id$        python_service.dart         2024-09-24
 *//**
 * @file        python_service.dart
 * @brief       Service for running Python scripts from Flutter
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  PythonService Python Service
/// @{
library;


import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// @brief Executes a Python function from a specified script
/// 
/// This function loads a Python script from the assets, writes it to
/// a temporary file, and executes it using the system's Python interpreter.
/// It captures the output or errors from the execution.
Future<String> runPythonFunction(String scriptPath, String functionName, String arguments) async {
  String pythonScript = await rootBundle.loadString('lib/services/$scriptPath'); ///< Loads the Python script from assets
  Directory tempDir = await getTemporaryDirectory(); ///< Gets the temporary directory for the app
  String tempPath = '${tempDir.path}/commands.py'; ///< Defines the path for the temporary script
  File tempFile = File(tempPath);
  await tempFile.writeAsString(pythonScript); ///< Writes the loaded script to a temporary file

  ProcessResult result = await Process.run('python', [tempPath, functionName, arguments]); ///< Runs the Python script with specified function and arguments
  
  if (result.exitCode == 0) {
    return result.stdout as String; ///< Returns the standard output if successful
  } else {
    throw Exception(result.stderr); ///< Throws an exception with the error output if the execution fails
  }
}
/** @} */
