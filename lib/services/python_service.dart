import 'dart:io';

Future<String> runPythonFunction(String scriptPath, String functionName, String arguments) async {

  String pythonScriptPath = 'lib/services/$scriptPath';


  ProcessResult result = await Process.run('python', [pythonScriptPath, functionName, arguments]);
  
  if (result.exitCode == 0) {
    return result.stdout as String;
  } else {
    throw Exception(result.stderr);
  }
}
