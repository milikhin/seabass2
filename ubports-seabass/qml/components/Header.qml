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
    icon: "package-x-generic-symbolic"
    visible: buildable
    enabled: buildEnabled
    onClicked: buildRequested()
  }
  CustomComponents.ToolButton {
    icon: "terminal-app-symbolic"
    onClicked: openTerminalApp()
  }
  CustomComponents.ToolButton {
    icon: "search"
    enabled: searchEnabled
    onClicked: search()
  }
  CustomComponents.ToolButton {
    icon: "save"
    enabled: canBeSaved
    onClicked: saveRequested()
  }
  CustomComponents.ToolButton {
    icon: "contextual-menu"
    onClicked: menu.open()

    Menu {
      id: menu
      y: parent.height
      modal: true
      CustomComponents.MenuItem {
        icon: keyboardExtensionEnabled ? "select" : "select-none"
        text: i18n.tr("Keyboard extension")
        enabled: searchEnabled
        onTriggered: keyboardExtensionToggled()
      }
      CustomComponents.MenuItem {
        icon: "settings"
        text: i18n.tr("Settings")
        onTriggered: settingsPageRequested()
      }
      CustomComponents.MenuItem {
        icon: "info"
        text: i18n.tr("About")
        onTriggered: aboutPageRequested()
      }
    }
  }
}
