/**
 * @file      tab_manager.dart
 * @author    Eduardo Abdala (eduardo.abdala@perto.com.br)
 * @brief     Contains the `TabManager` class that manages the tabs/screens in the app.
 *            It allows adding, removing, and selecting tabs/screens, as well as tracking the currently selected tab.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/// @addtogroup TabManager
/// @details   This file contains the `TabManager` class, which is used to manage tabs/screens in the application.
///            It stores a list of active screens (`ScreenModel`), allows for adding/removing screens, and selects
///            the current screen/tab. The `TabManager` notifies listeners when the tab list or selected index changes.
///
/// ============================
/// How to build this component
/// ============================
/// - Instantiate `TabManager` and attach it to your widget tree using `ChangeNotifierProvider` 
///   to allow other widgets to listen to the tab state.
///
/// ============================
/// How to use this component
/// ============================
/// - Use `addTab` to add a new tab to the screen list.
/// - Use `removeTab` to remove a tab by its index.
/// - Use `selectTab` to switch between tabs by specifying the index of the desired tab.
/// @{
library;


import 'package:flutter/material.dart';
import 'screen_model.dart';
import '../views/home_screen.dart';

/// @brief Manages the tabs/screens in the application.
/// 
/// The `TabManager` class tracks a list of active screens and allows for adding, removing, 
/// and selecting tabs/screens. It keeps track of the currently selected tab index and 
/// notifies listeners whenever the tab state changes.
class TabManager extends ChangeNotifier {
  final List<ScreenModel> _screens = [
    ScreenModel(title: 'Home', screen: const HomeScreen(), navigatorKey: GlobalKey<NavigatorState>()),
  ];
  int _selectedIndex = 0;

  /// @brief Gets the list of active screens/tabs.
  /// @return A list of `ScreenModel` representing the open tabs/screens.
  List<ScreenModel> get screens => _screens;

  /// @brief Gets the index of the currently selected tab.
  /// @return The index of the selected tab.
  int get selectedIndex => _selectedIndex;

  /// @brief Adds a new tab to the list of screens.
  /// 
  /// The method checks if the number of screens is less than 10 before adding a new screen/tab.
  /// Once added, it sets the new tab as the selected tab.
  /// 
  /// @param screen The `ScreenModel` object representing the new tab.
  void addTab(ScreenModel screen) {
    if (_screens.length < 10) {
      _screens.add(screen);
      _selectedIndex = _screens.length - 1;
      notifyListeners();
    }
  }

  /// @brief Removes a tab from the list of screens by its index.
  /// 
  /// After removing the tab, the method ensures that the selected index remains within valid bounds.
  /// If the removed tab was the currently selected one, it adjusts the selected index accordingly.
  /// 
  /// @param index The index of the tab to remove.
  void removeTab(int index) {
    if (index >= 0 && index < _screens.length) {
      _screens.removeAt(index);
      if (_selectedIndex >= _screens.length) {
        _selectedIndex = _screens.length - 1;
      }
      if (_selectedIndex < 0) {
        _selectedIndex = 0;
      }
      notifyListeners();
    }
  }

  /// @brief Selects a tab by its index.
  /// 
  /// This method updates the selected index to the specified value and notifies listeners of the change.
  /// 
  /// @param index The index of the tab to select.
  void selectTab(int index) {
    if (index >= 0 && index < _screens.length) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}

/** @}*/ // End of TabManager
