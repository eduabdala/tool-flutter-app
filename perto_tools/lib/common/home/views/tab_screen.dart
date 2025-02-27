/**
 * @file      tab_screen.dart
 * @author    Eduardo Abdala (eduardo.abdala@perto.com.br)
 * @brief     Provides the UI for managing tabs and screens in the app. 
 *            It allows adding, removing, selecting tabs, and handling theme changes.
 * @version   1.0
 * @date      2025-02-04
 * @note      Uses `TabManager` and `ThemeNotifier` for state management.
 */

/// @addtogroup TabScreen
/// @details   This file defines the `TabScreen` widget, which is responsible for displaying 
///            a dynamic tab interface with the ability to switch between tabs, add new ones, 
///            remove them, and toggle themes.
///
/// ============================
/// How to build this component
/// ============================
/// - Attach this widget to your widget tree where you need the tab navigation functionality.
/// - Ensure that `TabManager` and `ThemeNotifier` are provided higher up in the widget tree 
///   using `Provider`.
///
/// ============================
/// How to use this component
/// ============================
/// - Tap a tab to select it and view the associated screen.
/// - Use the close icon to remove a tab.
/// - Use the "Add" button to add new tabs (up to 10).
/// - Tap the home icon to reset the current tab's navigation state.
/// - Tap the theme icon to toggle between light and dark themes.
/// @{
library;


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/theme_provider.dart';
import '../models/screen_model.dart';
import '../models/tab_manager.dart';
import 'home_screen.dart';

/// @brief A screen widget that manages multiple tabs with navigation and theming features.
/// 
/// `TabScreen` is a stateful widget that enables tab-based navigation. Each tab can have its own 
/// screen with a unique `Navigator` to preserve its state. The widget also supports adding and 
/// removing tabs dynamically, and it provides a mechanism to toggle between light and dark themes.
class TabScreen extends StatelessWidget {
  const TabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tabManager = Provider.of<TabManager>(context);
    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      body: Column(
        children: [
          _buildTabBar(context, tabManager, themeProvider),
          Expanded(
            child: IndexedStack(
              index: tabManager.selectedIndex,
              children: tabManager.screens.map((screen) {
                // Create a Navigator for each tab and preserve its state
                return Navigator(
                  key: screen.navigatorKey,  // Use the Navigator's GlobalKey
                  onGenerateRoute: (RouteSettings settings) {
                    return MaterialPageRoute(
                      builder: (context) => screen.screen,
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// @brief Builds the tab bar, displaying tabs, an add button, and theme toggle button.
  /// 
  /// @param context The build context.
  /// @param tabManager The TabManager to manage tab actions.
  /// @param themeProvider The ThemeNotifier to manage theme state.
  /// @return The constructed tab bar UI.
  Widget _buildTabBar(BuildContext context, TabManager tabManager, ThemeNotifier themeProvider) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // Fixed Home button
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.blue,
            ),
            onPressed: () {
              // When pressed, reset the current tab's navigation state
              final currentTabIndex = tabManager.selectedIndex;
              final currentScreen = tabManager.screens[currentTabIndex];

              // Reset navigation state of the current tab
              currentScreen.navigatorKey.currentState?.popUntil((route) => route.isFirst);
            },
          ),
          _buildTabs(context, tabManager),
          _buildAddTabButton(context, tabManager),
         Tooltip(
            message: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            child: IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// @brief Builds the list of open tabs in a horizontal list view.
  /// 
  /// @param context The build context.
  /// @param tabManager The TabManager to retrieve the list of open tabs.
  /// @return A widget that displays the list of tabs.
  Widget _buildTabs(BuildContext context, TabManager tabManager) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabManager.screens.length,
        itemBuilder: (context, index) {
          return _buildTab(index, tabManager);
        },
      ),
    );
  }

  /// @brief Builds an individual tab with its title and close button.
  /// 
  /// @param index The index of the tab to be built.
  /// @param tabManager The TabManager to manage tab actions.
  /// @return A widget representing a single tab in the list.
  Widget _buildTab(int index, TabManager tabManager) {
    final screen = tabManager.screens[index];

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            tabManager.selectTab(index); // Select the tab
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: tabManager.selectedIndex == index ? Colors.blue : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(screen.title),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 16),
          onPressed: () {
            tabManager.removeTab(index);  // Remove the tab
          },
        ),
      ],
    );
  }

  /// @brief Builds the button to add a new tab.
  /// 
  /// @param context The build context.
  /// @param tabManager The TabManager to manage tab actions.
  /// @return The button widget for adding new tabs.
  Widget _buildAddTabButton(BuildContext context, TabManager tabManager) {
    return IconButton(
      icon: const Icon(Icons.add),
      onPressed: tabManager.screens.length < 10
          ? () {
              tabManager.addTab(ScreenModel(
                title: 'Tab ${tabManager.screens.length + 1}',
                screen: const HomeScreen(),
                navigatorKey: GlobalKey<NavigatorState>(),  // Assign a GlobalKey for each new tab
              ));
            }
          : null, // Prevent adding more than 10 tabs
    );
  }
}

/** @}*/ // End of TabScreen
