import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import "./tabs" as TabComponents
import "../generic/utils.js" as QmlJs

Item {
  id: root
  height: tabBar.height

  property real minTabLabelWidth: Suru.units.gu(8)
  property real maxTabLabelWidth: Suru.units.gu(30)
  property ListModel model

  property alias currentIndex: tabBar.currentIndex
  signal close(int index)
  signal closeAll()
  signal closeToTheRight(int index)

  MouseArea {
    anchors.fill: parent
    onWheel: {
      // no need to scroll if content width < container width
      if (tabBar.contentItem.contentWidth < root.width) {
        return
      }

      const step = Suru.units.gu(10)
      if (wheel.angleDelta.y > 0 || wheel.angleDelta.x > 0) {
        const minX = 0
        tabBar.contentItem.contentX = Math.max(minX, tabBar.contentItem.contentX - step)
      } else {
        const maxX = tabBar.contentItem.contentWidth - tabBar.width
        tabBar.contentItem.contentX = Math.min(maxX, tabBar.contentItem.contentX + step)
      }
    }
  }

  TabBar {
    id: tabBar
    anchors.topMargin: 1
    contentHeight: Suru.units.gu(4.5)
    width: parent.width

    Component.onCompleted: {
      // disable "scroll-animation" when switching between tabs
      tabBar.contentItem.highlightRangeMode = ListView.NoHighlightRange
      // allow scrolling past the selected tab
      tabBar.contentItem.snapMode = ListView.NoSnap
    }

    Repeater {
      id: repeater
      model: root.model

      onItemAdded: function(index) {
        tabBar.currentIndex = index
      }

      TabComponents.TabButton {
        maxLabelWidth: Math.min(root.width / 2, maxTabLabelWidth)
        minLabelWidth: minTabLabelWidth
        text: model.uniqueTitle
        hasChanges: model.hasChanges
        hasMoveLeft: model.index > 0
        hasMoveRight: model.index < root.model.count - 1
        isBusy: model.isBusy

        onClosed: root.close(model.index)
        onCloseAll: root.closeAll()
        onCloseToTheRight: root.closeToTheRight(model.index)
        onMoveLeft: function() {
          root.model.move(model.index, model.index - 1, 1)
        }
        onMoveRight: function(index) {
          root.model.move(model.index, model.index + 1, 1)
        }
      }
    }
  }
}

