import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

import '../common' as CustomComponents

Menu {
  modal: true
  property string contextPath

  signal renameTriggered()
  signal deleteTriggered()

  CustomComponents.MenuItem {
    iconName: "edit"
    text: i18n.tr("Rename...")
    onTriggered: renameTriggered()
  }
  CustomComponents.MenuItem {
    iconName: "delete"
    text: i18n.tr("Delete")
    onTriggered: deleteTriggered()
  }

  function show(mouseX, mouseY, path) {
    x = mouseX
    y = mouseY
    contextPath = path

    open()
  }
}
