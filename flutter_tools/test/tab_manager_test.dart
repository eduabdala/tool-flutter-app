import 'package:flutter_tools/common/home/models/screen_model.dart';
import 'package:flutter_tools/common/home/models/tab_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('TabManager', () {
    test('Adiciona uma nova aba', () {
      final tabManager = TabManager();
      final initialLength = tabManager.screens.length;

      tabManager.addTab(ScreenModel(
        title: 'Nova Aba',
        screen: Container(),
        navigatorKey: GlobalKey<NavigatorState>(),
      ));

      expect(tabManager.screens.length, initialLength + 1);
      expect(tabManager.screens[initialLength].title, 'Nova Aba');
    });

    test('Remove uma aba', () {
      final tabManager = TabManager();
      final initialLength = tabManager.screens.length;

      final screen = ScreenModel(
        title: 'Aba Removível',
        screen: Container(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      tabManager.addTab(screen);

      tabManager.removeTab(0);

      expect(tabManager.screens.length, initialLength);
    });

    test('Seleciona uma aba', () {
      final tabManager = TabManager();

      final screen1 = ScreenModel(
        title: 'Aba 1',
        screen: Container(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      final screen2 = ScreenModel(
        title: 'Aba 2',
        screen: Container(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      tabManager.addTab(screen1);
      tabManager.addTab(screen2);

      tabManager.selectTab(0);

      expect(tabManager.selectedIndex, 0);
      expect(tabManager.screens[tabManager.selectedIndex].title, 'Home');

      tabManager.selectTab(2);

      expect(tabManager.selectedIndex, 2);
      expect(tabManager.screens[tabManager.selectedIndex].title, 'Aba 2');
    });
  });
}
