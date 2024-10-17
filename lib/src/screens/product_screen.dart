/***********************************************************************
 * $Id$        product_screen.dart        2024-09-24
 *//**
 * @file        product_screen.dart
 * @brief       Product screen with dynamic theme support
 * @version     1.0
 * @date        24. Sep. 2024
 * @author      Eduardo Abdala
 *************************************************************************/
/// @addtogroup  ProductScreen Product Screen
/// @ingroup screens
/// @{
library;

import 'package:flutter/material.dart';
import '../models/screen.dart';
import 'dynamic_screen.dart';
import 'package:flutter_app/src/components/theme_provider.dart';
import 'package:provider/provider.dart';

/// @brief Class representing the product screen
/// 
/// This class displays a list of buttons, each corresponding to a product screen
/// defined in the `screens` list. It allows toggling between light and dark themes.
class ProductScreen extends StatelessWidget {
  final List<ScreenModel> screens; 

  /// @brief Constructor for the ProductScreen class
  /// 
  /// @param screens List of screen models to be displayed
  const ProductScreen({super.key, required this.screens});

  /// @brief Builds the user interface for the screen
  /// 
  /// @param context Current application context
  /// @return Widget Representation of the product screen
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark; 

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round), 
            onPressed: themeProvider.toggleTheme, 
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: screens.map((screen) => _buildScreenButton(context, screen)).toList(),
          ),
        ),
      ),
    );
  }

  /// @brief Builds a button for the product screen
  /// 
  /// @param context Current application context
  /// @param screen Model of the screen to be displayed
  /// @return Widget Representation of the screen button
  Widget _buildScreenButton(BuildContext context, ScreenModel screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          fixedSize: const Size(175, 40), 
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DynamicScreen(screen: screen), 
            ),
          );
        },
        child: Text(screen.title), 
      ),
    );
  }
}
/** @} */
