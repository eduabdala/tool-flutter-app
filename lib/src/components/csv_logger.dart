/***********************************************************************
 * $Id$        csv_logger.dart               2024-09-24
 *//**
 * @file        csv_logger.dart
 * @brief       Logger for appending data to a CSV file
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  CsvLogger CSV Logger
/// @{
library;


import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// @brief A class for logging data to a CSV file
/// 
/// This class provides functionality to append data with timestamps 
/// to a CSV file for persistent storage.
class CsvLogger {
  /// @brief Retrieves the file path for the log file
  /// 
  /// This method constructs the path for the status log file 
  /// in the application's documents directory.
  /// 
  /// @return Future<String> The path to the log file
  Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory(); ///< Gets the application's documents directory
    final filePath = '${directory.path}\\status_log.txt'; ///< Constructs the file path
    return filePath;
  }

  /// @brief Appends data to the log file
  /// 
  /// This method writes the provided data to the log file, 
  /// creating the file and adding a header if it does not exist.
  /// 
  /// @param data The data to be appended to the log file
  Future<void> appendData(String data) async {
    final filePath = await _getFilePath(); ///< Retrieves the file path
    final file = File(filePath); ///< Creates a File instance

    if (!await file.exists()) { ///< Checks if the file exists
      await file.writeAsString('Timestamp, Data\n'); ///< Writes header if the file is new
    }

    await file.writeAsString(data, mode: FileMode.append); ///< Appends data to the file
  }

  /// @brief Gets the file path for external use
  /// 
  /// This method provides access to the log file path for external use.
  /// 
  /// @return Future<String> The path to the log file
  Future<String> getFilePath() async {
    return await _getFilePath(); ///< Retrieves the file path
  }
}
/** @} */
