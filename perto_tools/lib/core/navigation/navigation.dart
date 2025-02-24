import 'package:flutter/material.dart';
import 'routes.dart';

void navigateToHome(BuildContext context) {
  Navigator.pushNamed(context, Routes.home);
}

void navigateToProduct(BuildContext context) {
  Navigator.pushNamed(context, Routes.product);
}

void navigateToTabScreen(BuildContext context) {
  Navigator.pushNamed(context, Routes.tab);
}
