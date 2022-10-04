import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import Ubuntu.Content 1.3

import "./common" as CustomComponents
import "../generic/utils.js" as QmlJs
import "./files" as FilesComponents

Item {
  id: root
  property bool isReady: false
  property bool isPage: false
  property bool showHidden: false
  property bool treeMode: false

  property string homeDir
  property real rowHeight: units.gu(4.5)

  signal closed()
  signal errorOccured(string errorMessage)
  signal fileSelected(string filePath)
  signal projectCreationInitialized(string dirName)

  Timer {
    id: timer
    running: false
    repeat: false

    property var callback
    onTriggered: callback()

    function setTimeout(callback, delay) {
      if (timer.running) {
        console.error("nested calls to setTimeout are not supported!");
        return;
      }
      timer.callback = callback;
      // note: an interval of 0 is directly triggered, so add a little padding
      timer.interval = delay + 1;
      timer.running = true;
    }
  }

  Connections {
    target: ContentHub
    onImportRequested: {
      // Import single file
      const url = transfer.items[0].url.toString()
      const fileName = QmlJs.getFileName(url)
      transfer.finalize()

      // Try to guess original file path by parsing filemanager logs
      // as there is no official API to open the original file
      var callback = function() {
        if (!isReady) {
          return timer.setTimeout(callback, 100)
        }

        directoryModel.guessFilePath(transfer.source, fileName, function(err, filePath) {
          if (err) {
            return errorOccured('Unable to open file: ' + err)
          }
          fileSelected(filePath)
        })
      }
      callback()
    }
  }

  ConfirmDialog {
    id: confirmDialog
    title: i18n.tr("Delete file?")
    okColor: Suru.theme === Suru.Dark ? Suru.darkNegative : Suru.lightNegative
    okText: i18n.tr("Delete")
  }
  FilesComponents.NewFileDialog {
    id: newFileDialog
    homeDir: parent.homeDir
  }
  FilesComponents.RenameDialog {
    id: renameDialog
    homeDir: parent.homeDir
  }
  FilesComponents.FileMenu {
    id: fileMenu
    onRenameTriggered: renameFile(contextPath)
    onDeleteTriggered: _rm(contextPath)
  }
  FilesComponents.DirectoryMenu {
    id: dirMenu
    onCreateTriggered: createFile(contextPath)
    onRenameTriggered: renameFile(contextPath)
    onDeleteTriggered: _rm(contextPath)
  }
  FilesComponents.DotDotMenu {
    id: dotDotMenu
    onCreateTriggered: createFile(contextPath)
  }

  ColumnLayout {
    anchors.fill: parent
    spacing: 0

    FilesComponents.Header {
      Layout.fillWidth: true

      id: header
      hasLeadingButton: root.isPage
      onLeadingAction: closed()
      title: i18n.tr("Files")
      subtitle: QmlJs.getPrintableDirPath(directoryModel.directory, homeDir)
      onClosed: root.closed()
      onFileCreationInitialized: root.createFile(directoryModel.directory)
      onProjectCreationInitialized: root.projectCreationInitialized(directoryModel.directory)
      onReloaded: directoryModel.load()
      onTreeModeChanged: root.treeMode = treeMode
      z: 1
    }

    ListView {
      id: list
      Layout.fillWidth: true
      Layout.fillHeight: true

      model: directoryModel.model
      delegate: Item {
        id: item
        height: rowHeight
        width: parent.width
        property var menu: model.isFile
          ? fileMenu
          : model.name === '..'
            ? dotDotMenu
            : dirMenu

        function _getWindowY(mouseY) {
          return mouseY + item.y + list.y - list.contentY
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          hoverEnabled: true

          onPressAndHold: {
            menu.show(mouseX, _getWindowY(mouseY), path)
          }
          onClicked: {
            if (mouse.button === Qt.RightButton) {
              return menu.show(mouseX, _getWindowY(mouseY), path)
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
            color: parent.containsMouse
              ? Suru.secondaryBackgroundColor
              : Suru.backgroundColor
            border {
              width: menu.visible && menu.contextPath === path
                ? units.dp(1)
                : 0
              color: Suru.highlightColor
            }
            Behavior on color {
              ColorAnimation {
                duration: Suru.animations.FastDuration
                easing: Suru.animations.EasingIn
              }
            }

            RowLayout {
              anchors.left: parent.left
              anchors.right: parent.right
              anchors.leftMargin: units.gu(2) * (model.level + 1)
              anchors.rightMargin: units.gu(2)
              anchors.verticalCenter: parent.verticalCenter
              spacing: units.gu(1)
              CustomComponents.Icon {
                Layout.preferredWidth: units.gu(2)
                Layout.preferredHeight: units.gu(2)
                name: model.isFile
                  ? getFileIcon(model.name)
                  : getDirIcon(model.path, model.isExpanded)
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
  }

  FilesComponents.FileModel {
    id: directoryModel
    rootDirectory: '/'
    prevDirectory: QmlJs.getNormalPath(homeDir)
    directory: QmlJs.getNormalPath(settings.restoreOpenedTabs
      ? settings.initialDir
      : homeDir)
    showDotDot: !treeMode

    onDirectoryChanged: {
      settings.initialDir = directory
    }
    onErrorOccured: function(err) {
      root.errorOccured(err)
    }
  }

  function createFile(dirPath) {
    const normalDirPath = QmlJs.getNormalPath(dirPath)
    newFileDialog.show(normalDirPath, function(fileName) {
      const filePath = QmlJs.getNormalPath(Qt.resolvedUrl(normalDirPath + '/' + fileName))
      fileSelected(filePath)
    })
  }
  function renameFile(filePath) {
    const originalFilePath = QmlJs.getNormalPath(filePath)
    renameDialog.show(originalFilePath, function(newFilePath) {
      directoryModel.rename(originalFilePath, newFilePath, function(err) {
        if (!err) {
          return
        }
        errorOccured(err)
      })
    })
  }

  function reload() {
    directoryModel.load()
  }

  function _rm(path) {
    confirmDialog.show({
        text: i18n.tr("%1 will be deleted").arg(QmlJs.getPrintableFilePath(path, homeDir)),
        onOk: function() {
          directoryModel.rm(path, function(err) {
            if (!err) {
              return
            }
            errorOccured(err)
          })
        },
        onCancel: function() {}
      })
  }

  function getDirIcon(path, isExpanded) {
    if (!treeMode) {
      return 'folder-symbolic'
    }

    if (isExpanded) {
      return 'view-collapse'
    }

    return 'view-expand'
  }

  function getFileIcon(fileName) {
    var extMatch = fileName.match(/\.([A-Za-z]+)$/)
    var ext = extMatch && extMatch[1]
    switch(ext) {
      case 'html':
        return 'text-html-symbolic'
      case 'css':
        return 'text-css-symbolic'
      case 'xml':
        return 'text-xml-symbolic'
      default:
        return 'text-x-generic-symbolic'
    }
  }
}
