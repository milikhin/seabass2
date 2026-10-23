import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2 as QQC2
import Lomiri.Components 1.3

QQC2.Popup {
  id: root

  signal tabSelected(string tabId)

  property alias model: list.model
  property ListModel tabsModel

  opacity: 0
  modal: true
  focus: true
  anchors.centerIn: parent
  width: Math.min(parent.width * 0.7, units.gu(40))
  height: list.height + padding * 2
  padding: 0

  enter: Transition {
    LomiriNumberAnimation { property: "scale"; from: 0.91; to: 1.0; duration: LomiriAnimation.SnapDuration }
  }

  exit: Transition {
    LomiriNumberAnimation { property: "scale"; from: 1.0; to: 0.91; duration: LomiriAnimation.SnapDuration }
  }

  Behavior on opacity { LomiriNumberAnimation { duration: LomiriAnimation.SnapDuration } }

  onClosed: {
    if (list.currentItem && list.currentItem.tabId) {
      tabSelected(list.currentItem.tabId)
    }
    showDelay.stop()
    opacity = 0
  }

  function show(forward) {
    if (forward) {
      list.currentIndex = 1
    } else {
      list.currentIndex = list.count - 1
    }
    showDelay.restart()
    open()
  }

  // Delay visually showing
  Timer {
    id: showDelay
    interval: 500
    onTriggered: opacity = 1
  }

  ListView {
    id: list

    focus: true
    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
    }
    height: Math.min(contentHeight, root.parent.height - units.gu(4))

    Keys.onPressed: (event) => {
      switch (event.key) {
        case Qt.Key_Tab:
          showDelay.stop()
          root.opacity = 1
          if (list.currentIndex === list.count - 1) {
            list.currentIndex = 0
          } else {
            list.incrementCurrentIndex()
          }
          break
        case Qt.Key_Backtab:
          showDelay.stop()
          root.opacity = 1
          if (list.currentIndex === 0) {
            list.currentIndex = list.count - 1
          } else {
            list.decrementCurrentIndex()
          }
          break
      }
    }

    Keys.onReleased: (event) => {
      switch (event.key) {
        case Qt.Key_Control:
          root.close()
          break;
      }
    }

    delegate: QQC2.ItemDelegate {
      readonly property var item: root.tabsModel.getTab(modelData)
      readonly property string tabId: item.id

      anchors {
        left: parent.left
        right: parent.right
      }
      text: item.title
      highlighted: ListView.isCurrentItem

      onClicked: {
        list.currentIndex = index
        root.close()
      }
    }
  }
}
