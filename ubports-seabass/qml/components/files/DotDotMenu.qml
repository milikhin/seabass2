import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

import '../common' as CustomComponents

Menu {
  modal: true
  property string contextPath

  signal createTriggered()

  CustomComponents.MenuItem {
    icon: "add"
    text: i18n.tr("New file...")
    onTriggered: createTriggered()
  }

  function show(mouseX, mouseY, path) {
    x = mouseX
    y = mouseY
    contextPath = path

    open()
  }
}
