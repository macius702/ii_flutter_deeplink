import 'dart:io';

void main() async {
  // Load the .env file
  final envFile = File('../../.env');
  final envContents = await envFile.readAsLines();

  // Parse the .env file
  final Map<String, String> envMap = {};
  for (var line in envContents) {
    if (line.isNotEmpty && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length == 2) {
        envMap[parts[0].trim()] = parts[1].trim();
      }
    }
  }

  // Retrieve values
  final greetBackendCanister = envMap['CANISTER_ID_GREET_BACKEND'] ?? 'default_backend_id';
  final greetFrontendCanister = envMap['CANISTER_ID_GREET_FRONTEND'] ?? 'default_frontend_id';

  // Generate the Dart file
  final output = '''
class Constants {
  static const String greetBackendCanister = $greetBackendCanister;
  static const String greetFrontendCanister = $greetFrontendCanister;
  static const String greetFrontendUrl = "https://\$greetFrontendCanister.icp0.io";
}
''';

  // Write to lib/constants.dart
  final file = File('lib/constants.dart');
  await file.writeAsString(output);
  print('Constants generated in lib/constants.dart');
}