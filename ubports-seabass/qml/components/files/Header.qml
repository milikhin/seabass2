import QtQuick 2.9
import Ubuntu.Components 1.3

PageHeader {
  signal closed()
  signal fileCreationInitialised()

  navigationActions:[
    Action {
      visible: isPage
      iconName: "back"
      text: i18n.tr("Close")
      onTriggered: closed()
    }
  ]
  trailingActionBar {
    actions: [
      Action {
        visible: !isPage
        iconName: "close"
        text: i18n.tr("Close")
        onTriggered: closed()
      },
      Action {
        iconName: "add"
        text: i18n.tr("New file...")
        onTriggered: fileCreationInitialised()
      }
    ]
  }
}