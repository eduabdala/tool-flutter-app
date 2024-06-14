import 'package:flutter/material.dart';
import '../models/screen.dart';
import '../components/component_factory.dart';

class DynamicScreen extends StatelessWidget {
  final ScreenModel screen;

  DynamicScreen({required this.screen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Text(screen.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            SingleChildScrollView(
              child: Column(
                children: screen.components.map((component) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 150, 
                      child: ComponentFactory.createComponent(component, context),
                    ),
                  );
                }).toList(),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}