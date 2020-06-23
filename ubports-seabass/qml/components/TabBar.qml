import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import QtQuick.Layouts 1.3

import "./tabs" as TabComponents
import "../generic/utils.js" as QmlJs

Rectangle {
  id: root

  property ListModel model
  property real minTabLabelWidth: units.gu(10)
  property real maxTabLabelWidth: units.gu(30)
  property real underlineWidth: units.gu(1) / 4
  property alias currentIndex: tabBar.currentIndex

  signal tabCloseRequested(int index)

  TabBar {
    id: tabBar
    anchors.fill: parent

    property real contentX

    background: Rectangle {
      color: theme.palette.normal.background
      border.width: 0
      MouseArea {
        anchors.fill: parent
        onWheel: {
          // no need to scroll if content width < container width
          if (tabBar.contentItem.contentWidth < root.width) {
            return
          }

          if (wheel.angleDelta.y > 0 || wheel.angleDelta.x > 0) {
            hbar.decrease()
          } else {
            hbar.increase()
          }
        }
      }
    }

    // Two-way binding for `contentX` between the TabBar and its contentItem, so it can be set manually
    Component.onCompleted: {
      contentXChanged.connect(function() {
        contentItem.contentX = contentX
      })
      contentItem.contentXChanged.connect(function() {
        contentX = contentItem.contentX
      })
    }

    Repeater {
      id: repeater
      model: root.model

      onItemAdded: function(index) {
        root.currentIndex = index
      }

      TabComponents.TabButton {
        height: root.height
        isActive: model.index === root.currentIndex
        maxLabelWidth: Math.min(root.width / 2, maxTabLabelWidth)
        minLabelWidth: minTabLabelWidth
        text: model.title
        hasChanges: model.hasChanges
        underlineWidth: root.underlineWidth
        isBusy: model.isBusy

        onClosed: tabCloseRequested(model.index)
      }
    }
  }

  ScrollBar {
    id: hbar
    hoverEnabled: true
    active: hovered || pressed
    orientation: Qt.Horizontal
    size: parent.width / tabBar.contentWidth

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.bottomMargin: root.underlineWidth

    onPositionChanged: {
      tabBar.contentX = position * tabBar.contentWidth
    }

    Component.onCompleted: {
      tabBar.contentXChanged.connect(function() {
        position = tabBar.contentX / tabBar.contentWidth
      })
    }
  }
}
