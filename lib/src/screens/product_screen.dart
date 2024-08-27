import 'package:flutter/material.dart';
import '../models/screen.dart';
import 'dynamic_screen.dart';
import 'package:flutter_app/src/components/theme_provider.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatelessWidget {
  final List<ScreenModel> screens;

  const ProductScreen({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Produtos'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ]
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ...screens.map((screen) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(175, 40)
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
              }),
            ],
          ),
        ),
      ),
    );
  }
}
