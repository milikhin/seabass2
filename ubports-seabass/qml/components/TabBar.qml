import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import "./tabs" as TabComponents
import "../generic/utils.js" as QmlJs

Item {
  id: root

  property real minTabLabelWidth: Suru.units.gu(8)
  property real maxTabLabelWidth: Suru.units.gu(30)
  property ListModel model

  property alias currentIndex: tabBar.currentIndex
  signal tabCloseRequested(int index)

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
    clip: true
    anchors.fill: parent

    Component.onCompleted: {
      tabBar.contentItem.highlightRangeMode = ListView.NoHighlightRange
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
        text: model.title
        hasChanges: model.hasChanges
        isActive: model.index === tabBar.currentIndex
        isBusy: model.isBusy

        onClosed: tabCloseRequested(model.index)
      }
    }
  }
}

