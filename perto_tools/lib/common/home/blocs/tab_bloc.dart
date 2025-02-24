/**
 * @file      tab_bloc.dart
 * @author    Eduardo Abdala (eduardo.abdala@perto.com.br)
 * @brief     Defines the TabBloc class for managing tab events in the application.
 *            This includes opening, selecting, closing, and resetting tabs.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/// @addtogroup TabManagement
/// @details   This file contains the `TabBloc` class that manages tab-related state
///            in the Flutter application. It handles tab events like opening, selecting,
///            closing, and resetting tabs (e.g., going to the home tab).
///
/// ============================
/// How to build this component
/// ============================
/// - The `TabBloc` class requires the `tab_event.dart` and `tab_state.dart` files for event 
///   and state management.
/// - The `ScreenModel` class should be defined for representing each tab.
/// - The `HomeScreen` widget is used for the content of each tab.
///
/// ============================
/// How to use this component
/// ============================
/// - Dispatch `OpenTabEvent` to open a new tab.
/// - Dispatch `SelectTabEvent` to select a specific tab.
/// - Dispatch `CloseTabEvent` to close a tab.
/// - Dispatch `GoToHomeEvent` to reset the tabs and show only the home screen.
/// @{
library;


import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../views/home_screen.dart';
import 'tab_event.dart';
import 'tab_state.dart';
import '../models/screen_model.dart';

/// @brief TabBloc manages the state of opened tabs in the application.
/// 
/// The `TabBloc` listens for various `TabEvent` events such as opening, selecting, closing,
/// and resetting tabs. It emits a `TabState` with the updated list of tabs and the selected
/// tab index in response to these events.
class TabBloc extends Bloc<TabEvent, TabState> {
  TabBloc() : super(TabState.initial()) {
    
    /**
     * @brief Event handler for opening a new tab.
     * 
     * This event adds a new tab to the opened tabs list and updates the selected index to the newly
     * opened tab. The new tab will display the `HomeScreen`.
     * 
     * @param event: OpenTabEvent containing the title of the new tab.
     * @param emit: The function used to emit the updated TabState.
     */
    on<OpenTabEvent>((event, emit) {
      final newTab = ScreenModel(
        title: event.title,
        screen: const HomeScreen(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      final newTabs = List<ScreenModel>.from(state.openedTabs)..add(newTab);
      emit(TabState(openedTabs: newTabs, selectedIndex: newTabs.length - 1));
    });

    /**
     * @brief Event handler for selecting a tab.
     * 
     * This event updates the selected index to the index of the selected tab.
     * 
     * @param event: SelectTabEvent containing the index of the tab to select.
     * @param emit: The function used to emit the updated TabState.
     */
    on<SelectTabEvent>((event, emit) {
      emit(TabState(openedTabs: state.openedTabs, selectedIndex: event.index));
    });

    /**
     * @brief Event handler for closing a tab.
     * 
     * This event removes the tab at the specified index and adjusts the selected tab index
     * accordingly. If the closed tab is the selected tab, the selected tab index is updated
     * to the next available tab.
     * 
     * @param event: CloseTabEvent containing the index of the tab to close.
     * @param emit: The function used to emit the updated TabState.
     */
    on<CloseTabEvent>((event, emit) {
      final newTabs = List<ScreenModel>.from(state.openedTabs)..removeAt(event.index);

      // Determine the new selected index after closing a tab
      int newIndex;

      if (event.index < state.selectedIndex) {
        // If the closed tab is before the selected tab, the selected index decreases by 1
        newIndex = state.selectedIndex - 1;
      } else if (event.index == state.selectedIndex) {
        // If the closed tab is the selected tab, select the last tab available
        if (newTabs.isNotEmpty) {
          newIndex = newTabs.length - 1;
        } else {
          newIndex = -1;  // No tabs left
        }
      } else {
        // If the closed tab is after the selected tab, the selected index remains unchanged
        newIndex = state.selectedIndex;
      }

      // Emit the new state with the updated tabs and selected index
      emit(TabState(openedTabs: newTabs, selectedIndex: newIndex));
    });

    /**
     * @brief Event handler for resetting tabs and showing only the home tab.
     * 
     * This event resets the tabs by removing all other tabs and displaying only the home tab.
     * The selected index is set to 0 as the home tab will be the only tab.
     * 
     * @param event: GoToHomeEvent.
     * @param emit: The function used to emit the updated TabState.
     */
    on<GoToHomeEvent>((event, emit) {
      final homeTab = ScreenModel(
        title: 'Home',
        screen: const HomeScreen(),
        navigatorKey: GlobalKey<NavigatorState>(),
      );
      final newTabs = [homeTab];  // Only the home tab is available
      emit(TabState(openedTabs: newTabs, selectedIndex: 0));
    });
  }
}

/** @}*/ // End of TabManagement
