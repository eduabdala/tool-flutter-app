/***********************************************************************
 * $Id$        json_loader.dart           2024-09-24
 *//**
 * @file        json_loader.dart
 * @brief       Utility for loading screen models from JSON files
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/** @addtogroup  JSONLoader JSON Loader
 * @{
 */
import 'dart:convert';
import 'package:flutter/services.dart';
import 'screen.dart';

/// @brief Loads screen models from JSON files located in the assets directory
/// 
/// This asynchronous function reads the AssetManifest to find all JSON 
/// files related to screen models, parses them, and creates a list of 
/// ScreenModel instances.
Future<List<ScreenModel>> loadScreens() async {
  final manifestContent = await rootBundle.loadString('AssetManifest.json'); ///< Loads the AssetManifest file
  final Map<String, dynamic> manifestMap = json.decode(manifestContent); ///< Decodes the manifest content into a map

  final screenFiles = manifestMap.keys
      .where((String key) => key.contains('lib/src/assets/screens_json/') && key.endsWith('.json')) ///< Filters JSON files for screen models
      .toList();

  List<ScreenModel> screens = []; ///< Initializes an empty list to store ScreenModel instances

  for (String path in screenFiles) {
    String jsonString = await rootBundle.loadString(path); ///< Loads the JSON content of each screen file
    final jsonResponse = json.decode(jsonString); ///< Decodes the JSON string into a dynamic object
    var screen = ScreenModel.fromJson(jsonResponse); ///< Creates a ScreenModel instance from the JSON object
    screens.add(screen); ///< Adds the ScreenModel to the list
  }

  return screens; ///< Returns the list of ScreenModel instances
}
/** @} */
