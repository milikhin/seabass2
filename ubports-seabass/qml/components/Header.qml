import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Morph.Web 0.1
import QtWebEngine 1.1
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import Ubuntu.Components.Popups 1.3
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0

PageHeader {
  id: root
  property bool navBarCanBeOpened: false
  property bool canBeSaved: false
  property bool buildable: false
  property bool buildEnabled: false
  property bool keyboardExtensionEnabled: false
  property bool searchEnabled: false

  signal navBarToggled()
  signal aboutPageRequested()
  signal saveRequested()
  signal buildRequested()
  signal keyboardExtensionToggled()
  signal search()

  navigationActions: [
    Action {
      visible: navBarCanBeOpened
      iconName: "document-open"
      text: i18n.tr("Files")
      onTriggered: navBarToggled()
    }
  ]

  trailingActionBar {
    numberOfSlots: buildable
      ? 4
      : 3
    actions: [
      Action {
        iconName: "save"
        text: i18n.tr("Save")
        enabled: canBeSaved
        shortcut: StandardKey.Save
        onTriggered: saveRequested()
      },
      Action {
        iconName: "package-x-generic-symbolic"
        text: i18n.tr("Build")
        visible: buildable
        enabled: buildEnabled
        onTriggered: buildRequested()
      },
      Action {
        iconName: "find"
        text: i18n.tr("Find/Replace")
        enabled: searchEnabled
        shortcut: StandardKey.Find
        onTriggered: search()
      },
      Action {
        iconName: keyboardExtensionEnabled ? "select" : "select-none"
        text: i18n.tr("Keyboard extension")
        enabled: searchEnabled
        onTriggered: keyboardExtensionToggled()
      },
      Action {
        iconName: "info"
        text: i18n.tr("About")
        onTriggered: aboutPageRequested()
      }
    ]
  }
}
