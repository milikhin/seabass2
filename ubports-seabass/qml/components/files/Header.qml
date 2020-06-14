import QtQuick 2.9
import Ubuntu.Components 1.3

PageHeader {
  property bool treeMode: false

  signal closed()
  signal fileCreationInitialised()
  signal reloaded()

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
        iconName: "add"
        text: i18n.tr("New file...")
        onTriggered: fileCreationInitialised()
      },
      Action {
        iconName: treeMode ? "select" : "select-none"
        text: i18n.tr("Tree mode")
        onTriggered: treeMode = !treeMode
      },
      Action {
        iconName: "reload"
        text: i18n.tr("Reload")
        onTriggered: reloaded()
      },
      Action {
        visible: !isPage
        iconName: "close"
        text: i18n.tr("Close")
        onTriggered: closed()
      }
    ]
    numberOfSlots: 1
  }
}