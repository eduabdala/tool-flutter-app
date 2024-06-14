import 'dart:convert';
import 'package:flutter/services.dart';
import 'screen.dart';

Future<List<ScreenModel>> loadScreens() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json');
  final Map<String, dynamic> manifestMap = json.decode(manifestContent);

  final screenFiles = manifestMap.keys
      .where((String key) => key.contains('lib/assets/screens_json/') && key.endsWith('.json'))
      .toList();

  List<ScreenModel> screens = [];

  for (String path in screenFiles) {
    String jsonString = await rootBundle.loadString(path);
    final jsonResponse = json.decode(jsonString);
    var screen = ScreenModel.fromJson(jsonResponse);
    screens.add(screen);
  }

  return screens;
}