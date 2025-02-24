/**
 * @file      tab_event.dart
 * @author    Eduardo Abdala (eduardo.abdala@perto.com.br)
 * @brief     Defines various events for tab management in the application.
 *            These events control actions like opening, closing, selecting, and resetting tabs.
 * @version   1.0
 * @date      2025-02-04
 * @copyright Copyright (c) 2025
 */

/**
 * @addtogroup TabEvents
 * @details   This file contains the definitions of events related to tab management in the 
 *            Flutter application. The events represent actions like opening, closing, 
 *            selecting, and resetting tabs.
 *
 * ============================
 * How to build this component
 * ============================
 * - Define the necessary events for managing tab states in your app.
 * - These events should be used by the `TabBloc` class to handle tab interactions.
 *
 * ============================
 * How to use this component
 * ============================
 * - Dispatch `OpenTabEvent` to open a new tab.
 * - Dispatch `CloseTabEvent` to close a tab.
 * - Dispatch `SelectTabEvent` to select a specific tab.
 * - Dispatch `GoToHomeEvent` to reset tabs and go to the home screen.
 * @{
 */

/// @brief Abstract class for representing a tab-related event.
/// 
/// This is the base class for all events related to tab management. All tab events extend
/// from this class.
abstract class TabEvent {}

/// @brief Event for opening a new tab.
/// 
/// This event is used when a new tab is opened in the application. It includes the title
/// of the tab being opened.
/// 
/// @param title: The title of the tab to open.
class OpenTabEvent extends TabEvent {
  final String title;

  OpenTabEvent(this.title);
}

/// @brief Event for closing an existing tab.
/// 
/// This event is used when a tab is closed in the application. It specifies the index
/// of the tab to be closed.
/// 
/// @param index: The index of the tab to close.
class CloseTabEvent extends TabEvent {
  final int index;

  CloseTabEvent(this.index);
}

/// @brief Event for selecting an existing tab.
/// 
/// This event is used when a user selects a tab from the list of opened tabs. The event
/// provides the index of the tab to select.
/// 
/// @param index: The index of the tab to select.
class SelectTabEvent extends TabEvent {
  final int index;

  SelectTabEvent(this.index);
}

/// @brief Event for resetting to the home tab.
/// 
/// This event is used when the app is reset to show only the home tab, typically when
/// navigating back to the home screen or clearing other opened tabs.
class GoToHomeEvent extends TabEvent {}

/// @brief Event for initializing or resetting the tab state.
/// 
/// This event is used for initialization or setting up the tab state to its default.
class InitialEvent extends TabEvent {}

/** @}*/ // End of TabEvents
