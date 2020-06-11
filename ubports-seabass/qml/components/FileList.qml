import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

import "../generic/utils.js" as QmlJs
import "./files" as FilesComponents

ListView {
  id: root
  property bool isPage: false
  property bool showHidden: false
  property string homeDir
  property real rowHeight: units.gu(4.5)

  readonly property string backgroundColor: theme.palette.normal.background
  readonly property string textColor: theme.palette.normal.backgroundText

  signal closed()
  signal fileCreationInitialised(string dirPath)
  signal fileSelected(string filePath)

  header: FilesComponents.Header {
    title: i18n.tr("Files")
    subtitle: directoryModel.getPrintableDirPath()
    onClosed: root.closed()
    onFileCreationInitialised: root.fileCreationInitialised(directoryModel.getDirPath())
    onReloaded: directoryModel.load()
  }

  model: directoryModel.model
  delegate: ListItem {
    height: rowHeight
    color: backgroundColor
    onClicked: {
      if (model.isDir) {
        return directoryModel.directory = model.path
      }

      fileSelected(model.path)
      // directoryModel.toggleExpanded(model.path)
    }

    RowLayout {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: units.gu(2)
      anchors.rightMargin: units.gu(2)
      anchors.verticalCenter: parent.verticalCenter
      spacing: units.gu(1)

      Icon {
        height: parent.height
        name: model.isFile ? QmlJs.getFileIcon(model.name) : 'folder-symbolic'
        color: textColor
      }
      Label {
        Layout.fillWidth: true
        Layout.fillHeight: true

        elide: Text.ElideRight
        text: model.name
        color: textColor
      }
    }
  }

  ScrollBar.vertical: ScrollBar {}

  FilesComponents.FileModel {
    id: directoryModel
    rootDirectory: QmlJs.getNormalPath(homeDir)
    directory: rootDirectory
  }

  function reload() {
    directoryModel.load()
  }
}
