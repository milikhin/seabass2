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
  property bool keyboardExtensionAvailable: false

  signal navBarToggled()
  signal aboutPageRequested()
  signal saveRequested()
  signal buildRequested()
  signal keyboardExtensionToggled()

  navigationActions: [
    Action {
      visible: navBarCanBeOpened
      iconName: "document-open"
      text: i18n.tr("Files")
      onTriggered: navBarToggled()
    }
  ]

  trailingActionBar {
    actions: [
      Action {
        iconName: "info"
        text: i18n.tr("About")
        onTriggered: aboutPageRequested()
      },
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
        iconName: "preferences-desktop-keyboard-shortcuts-symbolic"
        text: i18n.tr("Toggle keyboard extension")
        visible: keyboardExtensionAvailable
        onTriggered: keyboardExtensionToggled()
      }
    ]
  }
}
