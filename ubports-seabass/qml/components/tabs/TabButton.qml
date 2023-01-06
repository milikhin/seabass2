import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import Lomiri.Components 1.3 as UITK

TabButton {
  id: root
  padding: 0
  height: parent.height
  property real minLabelWidth: 0
  property real maxLabelWidth: Infinity
  property bool isBusy: false
  property bool hasChanges: false
  property alias hasMoveLeft: contextMenu.hasMoveLeft
  property alias hasMoveRight: contextMenu.hasMoveRight

  readonly property real tabPadding: Suru.units.gu(1)

  signal closed()
  signal closeAll()
  signal closeToTheRight()
  signal moveLeft()
  signal moveRight()

  property string backgroundColor: theme.palette.normal.background
  property string accentColor: theme.palette.normal.focus

  width: tabLabel.width + hasChangesIcon.width + closeButton.width + tabPadding

  contentItem: Rectangle {
    color: "transparent"
    border {
      width: Suru.units.dp(1)
      color: contextMenu.visible ? Suru.highlightColor : "transparent"
    }
    opacity: root.checked || root.down || root.hovered ? 1.0 : 0.7

    RowLayout {
      anchors.fill: parent
      spacing: 0

      Behavior on opacity {
        NumberAnimation {
          duration: Suru.animations.FastDuration
          easing: Suru.animations.EasingIn
        }
      }

      MouseArea {
        Layout.fillWidth: true
        Layout.fillHeight: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MidButton

        onPressAndHold: {
          contextMenu.show(mouseX, mouseY)
        }
        onClicked: {
          if (mouse.button === Qt.RightButton) {
            return contextMenu.show(mouseX, mouseY)
          }
          if (mouse.button === Qt.MidButton) {
            return root.closed()
          }

          root.checked = true
        }

        TabMenu {
          id: contextMenu
          onMoveLeft: root.moveLeft()
          onMoveRight: root.moveRight()
          onCloseAll: root.closeAll()
          onCloseToTheRight: root.closeToTheRight()
        }

        Row {
          anchors.fill: parent
          anchors.leftMargin: tabPadding

          Label {
            id: tabLabel
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            text: root.text + (isBusy ? " [please wait...]" : "")
            color: Suru.foregroundColor
            Component.onCompleted: {
              tabLabel.width = Math.max(
                Math.min(contentWidth, root.maxLabelWidth),
                root.minLabelWidth
              )
              root.maxLabelWidthChanged.connect(function() {
                tabLabel.width = undefined
                tabLabel.width = Math.max(
                  Math.min(contentWidth, root.maxLabelWidth),
                  root.minLabelWidth
                )
              })
              textChanged.connect(function() {
                tabLabel.width = undefined
                tabLabel.width = Math.max(
                  Math.min(contentWidth, root.maxLabelWidth),
                  root.minLabelWidth
                )
              })
            }
          }
          Label {
            id: hasChangesIcon
            text: ' *'
            visible: hasChanges
            anchors.verticalCenter: parent.verticalCenter
            color: Suru.highlightColor
          }
        }
      }

      Item {
        id: closeButton
        Layout.fillHeight: true
        width: closeIcon.width + tabPadding * 2

        UITK.Icon {
          id: closeIcon
          name: isBusy ? 'package-x-generic-symbolic' : 'close'
          height: tabLabel.height
          width: Suru.units.gu(2)
          anchors.centerIn: parent
          color: isBusy ? Suru.highlightColor : tabLabel.color
        }
        MouseArea {
          enabled: !isBusy
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: closed()
        }
      }
    }
  }
}
