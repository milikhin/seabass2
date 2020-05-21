import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import QtQuick.Layouts 1.3

import "./tabs" as TabComponents
import "../generic/utils.js" as QmlJs

TabBar {
  id: root
  property ListModel model
  property real minTabLabelWidth: units.gu(10)
  property real maxTabLabelWidth: units.gu(30)
  signal tabClosed(int index)

  background: Rectangle {
    color: theme.palette.normal.background
    border.width: 0
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
      text: model.name
      hasChanges: model.hasChanges

      onClosed: {
        tabClosed(model.index)
      }
    }
  }
}
