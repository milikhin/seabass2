import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

import '../common' as CustomComponents

Menu {
  modal: true
  property bool isDirectoryMenu
  property bool isDotDotMenu
  property string contextPath

  signal createTriggered()
  signal renameTriggered()
  signal deleteTriggered()

  CustomComponents.MenuItem {
    icon: "add"
    text: i18n.tr("Create file...")
    visible: isDirectoryMenu
    onTriggered: createTriggered()
  }
  CustomComponents.MenuItem {
    icon: "edit"
    text: i18n.tr("Rename...")
    visible: !isDotDotMenu
    onTriggered: renameTriggered()
  }
  CustomComponents.MenuItem {
    icon: "delete"
    text: i18n.tr("Delete")
    visible: !isDotDotMenu
    onTriggered: deleteTriggered()
  }

  function show(mouseX, mouseY, path, isDir, isDotDot) {
    x = mouseX
    y = mouseY
    contextPath = path
    isDirectoryMenu = isDir
    isDotDotMenu = isDotDot

    open()
  }
}
