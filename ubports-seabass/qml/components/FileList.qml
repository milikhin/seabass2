import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0

import Ubuntu.Components 1.3 as UITK

import "../generic/utils.js" as QmlJs
import "./files" as FilesComponents

Item {
  id: root
  property bool isPage: false
  property bool showHidden: false
  property string homeDir
  property real rowHeight: units.gu(4.5)
  property bool treeMode: false

  signal closed()
  signal errorOccured(string errorMessage)
  signal fileSelected(string filePath)

  function createFile(dirPath) {
    const normalDirPath = QmlJs.getNormalPath(dirPath)
    newFileDialog.show(normalDirPath, function(fileName) {
      const filePath = QmlJs.getNormalPath(Qt.resolvedUrl(normalDirPath + '/' + fileName))
      fileSelected(filePath)
    })
  }

  function reload() {
    directoryModel.load()
  }

  NewFileDialog {
    id: newFileDialog
    homeDir: parent.homeDir
  }

  FilesComponents.Header {
    id: header
    flickable: list
    title: i18n.tr("Files")
    subtitle: directoryModel.getPrintableDirPath()
    onClosed: root.closed()
    onFileCreationInitialised: root.createFile(directoryModel.getDirPath())
    onReloaded: directoryModel.load()
    onTreeModeChanged: root.treeMode = treeMode
    z: 1
  }

  ContextMenu {
    id: menu
    onCreateTriggered: {
      createFile(contextPath)
    }
  }

  ListView {
    id: list
    anchors.fill: parent

    model: directoryModel.model
    delegate: Item {
      id: item
      height: rowHeight
      width: parent.width
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressAndHold: {
          menu.show(mouseX, mouseY + item.y - list.contentY, path, isDir)
        }
        onClicked: {
          if (mouse.button === Qt.RightButton) {
            // console.log(mouseY, list.y, item.y)
            return menu.show(mouseX, mouseY + item.y - list.contentY, path, isDir)
          }

          if (model.isDir) {
            if (treeMode) {
              return directoryModel.toggleExpanded(model.path)
            }
            return directoryModel.directory = model.path
          }

          fileSelected(model.path)
        }

        Rectangle {
          anchors.fill: parent
          color: Suru.backgroundColor
          border {
            width: menu.visible && menu.contextPath === path ? units.dp(1) : 0
            color: Suru.highlightColor
          }
          RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: units.gu(2) * (model.level + 1)
            anchors.rightMargin: units.gu(2)
            anchors.verticalCenter: parent.verticalCenter
            spacing: units.gu(1)
            UITK.Icon {
              height: parent.height
              name: model.isFile
                ? QmlJs.getFileIcon(model.name)
                : directoryModel.getDirIcon(model.path, model.isExpanded)
            }
            Label {
              Layout.fillWidth: true
              Layout.fillHeight: true

              elide: Text.ElideRight
              text: model.name
            }
          }
        }
      }
    }

    ScrollBar.vertical: ScrollBar {}
  }

  FilesComponents.FileModel {
    id: directoryModel
    rootDirectory: '/'
    directory: QmlJs.getNormalPath(homeDir)
    showDotDot: !treeMode

    onErrorOccured: function(error) {
      root.errorOccured(error)
    }
  }
}
