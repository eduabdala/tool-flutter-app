import 'dart:io';

void runPythonFunction(String functionName, String arguments) {
// Caminho para o script Python
String pythonScriptPath = 'lib\\services\\thermal_printer\\commands.py'; // Substitua pelo caminho correto

// Argumentos que serão passados para o script Python
//List<String> arguments = ['cortar', 'arg2']; // Substitua pelos argumentos necessários

// Executando o script Python
Process.run('python', [pythonScriptPath, functionName, arguments]).then((ProcessResult result) {
if (result.exitCode == 0) {
print('Função Python $functionName executada com sucesso.');
print('Saída do Python:');
print(result.stdout);
} else {
print('Erro ao executar a função Python $functionName.');
print('Erro:');
print(result.stderr);
}
}).catchError((error) {
print('Erro ao executar a função Python $functionName: $error');
});
}