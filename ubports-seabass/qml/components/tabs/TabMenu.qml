import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

import '../common' as CustomComponents

Menu {
  modal: true
  property bool hasMoveLeft
  property bool hasMoveRight

  signal moveLeft()
  signal moveRight()
  signal closeAll()
  signal closeToTheRight()

  CustomComponents.MenuItem {
    iconName: "toolkit_arrow-left"
    text: i18n.tr("Move left")
    onTriggered: moveLeft()
    enabled: hasMoveLeft
  }
  CustomComponents.MenuItem {
    iconName: "toolkit_arrow-right"
    text: i18n.tr("Move right")
    onTriggered: moveRight()
    enabled: hasMoveRight
  }
  CustomComponents.MenuItem {
    iconName: "close"
    text: i18n.tr("Close to the Right")
    onTriggered: closeToTheRight()
    enabled: hasMoveRight
  }
  CustomComponents.MenuItem {
    iconName: "close"
    text: i18n.tr("Close All")
    onTriggered: closeAll()
  }

  function show(mouseX, mouseY) {
    x = mouseX
    y = mouseY

    open()
  }
}
