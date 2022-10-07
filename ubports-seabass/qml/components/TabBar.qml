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
  property var currentTab: model.get(currentIndex)

  property alias currentIndex: tabBar.currentIndex

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

      TabComponents.TabButton {
        maxLabelWidth: Math.min(root.width / 2, maxTabLabelWidth)
        minLabelWidth: minTabLabelWidth
        text: model.uniqueTitle
        hasChanges: model.hasChanges
        hasMoveLeft: model.index > 0
        hasMoveRight: model.index < root.model.count - 1
        isBusy: model.isBusy

        onClosed: _closeTabs([model])
        onCloseAll: _closeTabs(root.model.listFiles())
        onCloseToTheRight: _closeTabs(root.model.listFiles().slice(startIndex + 1))
        onMoveLeft: function() {
          root.model.move(model.index, model.index - 1, 1)
        }
        onMoveRight: function(index) {
          root.model.move(model.index, model.index + 1, 1)
        }
      }
    }
  }

  SaveDialog {
    id: saveDialog
  }

  function _closeTabs(tabs) {
    if (tabs.length === 0) {
      return
    }

    const tab = tabs.shift()
    if (!tab.hasChanges) {
      return __close()
    }

    saveDialog.show(tab.filePath, {
      onSaved: function() {
        api.requestSaveAndClose(tab.filePath)
        _closeTabs(tabs)
      },
      onDismissed: __close
    })

    function __close() {
      model.close(tab.id)
      _closeTabs(tabs)
    }
  }
}

