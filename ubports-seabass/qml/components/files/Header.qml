import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import '../common' as CustomComponents

ColumnLayout {
  id: root

  property bool treeMode: false
  property bool isLibertineEnabled: false
  property bool currentFileIsTerminal: false

  property alias title: mainToolBar.title
  property alias subtitle: mainToolBar.subtitle
  property alias hasLeadingButton: mainToolBar.hasLeadingButton

  signal leadingAction()
  signal closed()
  signal fileCreationInitialized()
  signal projectCreationInitialized()
  signal reloaded()
  signal goHome()
  signal goUp()
  signal setPathToCurrentFile()

  CustomComponents.ToolBar {
    id: mainToolBar

    Layout.fillWidth: true

    onLeadingAction: root.leadingAction()

    CustomComponents.ToolButton {
      text: i18n.tr("Close")
      iconName: "close"
      visible: !hasLeadingButton
      onClicked: root.closed()
    }
  }

  ToolBar {
    Layout.fillWidth: true

    RowLayout {
      anchors.fill: parent

      CustomComponents.ToolButton {
        text: i18n.tr("Home")
        iconName: "go-home"
        onClicked: root.goHome()
      }
      CustomComponents.ToolButton {
        text: i18n.tr("Go Up")
        iconName: "go-up"
        onClicked: root.goUp()
      }
      CustomComponents.ToolButton {
        text: i18n.tr("Set path from current file")
        iconName: "stock_document"
        visible: !root.currentFileIsTerminal
        onClicked: root.setPathToCurrentFile()
      }
      CustomComponents.ToolButton {
        text: i18n.tr("Reload")
        iconName: "reload"
        onClicked: root.reloaded()
      }

      // Spacer
      RowLayout {}

      CustomComponents.ToolButton {
        iconName: "contextual-menu"
        onClicked: menu.open()

        Menu {
          id: menu
          y: parent.height
          modal: true
          CustomComponents.MenuItem {
            iconName: "add"
            text: i18n.tr("New file...")
            onTriggered: root.fileCreationInitialized()
          }
          CustomComponents.MenuItem {
            iconName: "add"
            text: i18n.tr("New project...")
            onTriggered: root.projectCreationInitialized()
            visible: root.isLibertineEnabled
          }
          CustomComponents.MenuItem {
            iconName: root.treeMode ? "select" : "select-none"
            text: i18n.tr("Tree mode")
            onTriggered: root.treeMode = !root.treeMode
          }
        }
      }
    }
  }
}
