import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2

Menu {
  modal: true
  property bool isDirectoryMenu
  property string contextPath

  signal createTriggered()
  signal renameTriggered()
  signal deleteTriggered()

  MenuItem {
    text: i18n.tr("Create file...")
    visible: isDirectoryMenu
    height: isDirectoryMenu ? undefined: 0
    onTriggered: createTriggered()
  }
  MenuItem {
    text: i18n.tr("Rename...")
    onTriggered: renameTriggered()
  }
  MenuItem {
    text: i18n.tr("Delete")
    onTriggered: deleteTriggered()
  }

  function show(mouseX, mouseY, path, isDir) {
    x = mouseX
    y = mouseY
    contextPath = path
    isDirectoryMenu = isDir

    open()
  }
}