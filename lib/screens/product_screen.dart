import 'package:flutter/material.dart';
import '../models/screen.dart';
import 'dynamic_screen.dart';

class ProductScreen extends StatelessWidget {
  final List<ScreenModel> screens;

  const ProductScreen({super.key, required this.screens});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Produtos'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...screens.map((screen) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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