/**
 * @file      tab_state.dart
 * @author    Eduardo Abdala (eduardo.abdala@perto.com.br)
 * @brief     Contains classes for managing the state of tabs in the application,
 *            including opening, closing, and selecting tabs.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/// @addtogroup TabState
/// @details   This file contains the `TabState` and `TabStateProvider` classes, 
///            which are responsible for managing the state of opened tabs in the application.
///            The `TabState` class represents the state of tabs, including the list of opened tabs 
///            and the selected tab index, while the `TabStateProvider` manages and modifies the state 
///            using methods like adding, removing, and selecting tabs.
///
/// ============================
/// How to build this component
/// ============================
/// - Use `TabState` to represent the current state of tabs.
/// - The `TabStateProvider` class can be used with the `ChangeNotifierProvider` to manage 
///   the state of tabs across the application.
///
/// ============================
/// How to use this component
/// ============================
/// - `TabState` is used to store the state of opened tabs and the index of the selected tab.
/// - `TabStateProvider` is used to add, remove, select tabs and to notify listeners whenever the state changes.
/// @{
library;


import 'package:flutter/material.dart';
import '../models/screen_model.dart';
import '../views/home_screen.dart';

/// @brief Represents the state of tabs in the application.
/// 
/// This class stores the list of opened tabs and the index of the currently selected tab.
/// It includes an initial state method that initializes the state with a default "Home" tab.
class TabState {
  final List<ScreenModel> openedTabs; ///< List of opened tabs.
  final int selectedIndex; ///< Index of the selected tab.

  /// @brief Constructor to create an instance of TabState.
  /// 
  /// @param openedTabs: A list of ScreenModel representing opened tabs.
  /// @param selectedIndex: The index of the currently selected tab.
  TabState({required this.openedTabs, required this.selectedIndex});

  /// @brief Factory method to create an initial TabState with a default "Home" tab.
  /// 
  /// @return A TabState instance with one "Home" tab in the openedTabs list and selectedIndex as 0.
  factory TabState.initial() {
    return TabState(
      openedTabs: [
        ScreenModel(
          title: 'Home',
          navigatorKey: GlobalKey<NavigatorState>(),
          screen: Navigator(
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
              );
            },
          ),
        ),
      ],
      selectedIndex: 0,
    );
  }
}

/// @brief A provider class that manages the state of tabs.
/// 
/// This class allows adding, removing, selecting tabs, and notifying listeners when the state changes.
/// It is used with the `ChangeNotifierProvider` to allow the state to be observed and updated across the application.
class TabStateProvider with ChangeNotifier {
  List<ScreenModel> _screens = []; ///< List of screens (tabs) being tracked.
  String? _selectedId; ///< The ID of the selected tab.

  /// @brief Retrieves the list of screens (tabs).
  /// 
  /// @return A list of ScreenModel instances representing the opened tabs.
  List<ScreenModel> get screens => _screens;

  /// @brief Retrieves the ID of the selected tab.
  /// 
  /// @return The ID of the selected tab.
  String? get selectedId => _selectedId;

  /// @brief Adds a new tab to the opened tabs list.
  /// 
  /// This method updates the state by adding a new tab and selecting it.
  /// 
  /// @param screen: The ScreenModel representing the tab to be added.
  void addTab(ScreenModel screen) {
    _screens.add(screen);
    _selectedId = screen.id;
    notifyListeners();
  }

  /// @brief Removes a tab from the opened tabs list.
  /// 
  /// This method updates the state by removing the tab with the provided ID.
  /// If tabs remain, the first tab is selected; otherwise, the selected tab ID is set to null.
  /// 
  /// @param id: The ID of the tab to be removed.
  void removeTab(String id) {
    _screens.removeWhere((screen) => screen.id == id);
    if (_screens.isNotEmpty) {
      _selectedId = _screens.first.id;
    } else {
      _selectedId = null;
    }
    notifyListeners();
  }

  /// @brief Selects a tab by its ID.
  /// 
  /// This method updates the selected tab to the tab with the provided ID.
  /// 
  /// @param id: The ID of the tab to select.
  void selectTab(String id) {
    _selectedId = id;
    notifyListeners();
  }

  /// @brief Sets the list of screens (tabs) for the application.
  /// 
  /// This method replaces the current list of tabs with the provided list.
  /// 
  /// @param screens: A list of ScreenModel instances to replace the current tabs.
  void setTabs(List<ScreenModel> screens) {
    _screens = screens;
    if (screens.isNotEmpty) {
      _selectedId = screens.first.id;
    }
    notifyListeners();
  }
}

/** @}*/ // End of TabState
