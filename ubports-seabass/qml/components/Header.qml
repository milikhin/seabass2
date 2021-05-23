import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import './common' as CustomComponents

CustomComponents.ToolBar {
  id: root

  property bool navBarCanBeOpened: false
  property bool canBeSaved: false
  property bool buildable: false
  property bool buildEnabled: false
  property bool keyboardExtensionEnabled: false
  property bool searchEnabled: false
  property bool terminalEnabled: false

  signal navBarToggled()
  signal aboutPageRequested()
  signal settingsPageRequested()
  signal saveRequested()
  signal buildRequested()
  signal keyboardExtensionToggled()
  signal search()
  signal openTerminalApp()

  hasLeadingButton: navBarCanBeOpened
  leadingIcon: "document-open"
  onLeadingAction: navBarToggled()

  readonly property var saveShortcut: Shortcut {
    sequence: StandardKey.Save
    onActivated: saveRequested()
  }
  readonly property var findShortcut: Shortcut {
    sequence: StandardKey.Find
    onActivated: searchEnabled ? search() : Function.prototype
  }

  CustomComponents.ToolButton {
    iconName: "package-x-generic-symbolic"
    visible: buildable
    enabled: buildEnabled
    onClicked: buildRequested()
  }
  CustomComponents.ToolButton {
    iconName: "terminal-app-symbolic"
    enabled: terminalEnabled
    onClicked: openTerminalApp()
  }
  CustomComponents.ToolButton {
    iconName: "search"
    enabled: searchEnabled
    onClicked: search()
  }
  CustomComponents.ToolButton {
    iconName: "save"
    enabled: canBeSaved
    onClicked: saveRequested()
  }
  CustomComponents.ToolButton {
    iconName: "contextual-menu"
    onClicked: menu.open()

    Menu {
      id: menu
      y: parent.height
      modal: true
      CustomComponents.MenuItem {
        iconName: keyboardExtensionEnabled ? "select" : "select-none"
        text: i18n.tr("Keyboard extension")
        enabled: searchEnabled
        onTriggered: keyboardExtensionToggled()
      }
      CustomComponents.MenuItem {
        iconName: "settings"
        text: i18n.tr("Settings")
        onTriggered: settingsPageRequested()
      }
      CustomComponents.MenuItem {
        iconName: "info"
        text: i18n.tr("About")
        onTriggered: aboutPageRequested()
      }
    }
  }
}
