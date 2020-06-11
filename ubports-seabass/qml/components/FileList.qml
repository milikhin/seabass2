import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

import "../generic/utils.js" as QmlJs
import "./files" as FilesComponents

import io.thp.pyotherside 1.4

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

  model: folderModel
  header: FilesComponents.Header {
    title: i18n.tr("Files")
    subtitle: folderModel.getPrintableDirPath()
    onClosed: root.closed()
    onFileCreationInitialised: root.fileCreationInitialised(folderModel.getDirPath())
  }
  delegate: ListItem {
    height: rowHeight
    color: backgroundColor

    onClicked: {
      if (model.isFile) {
        return fileSelected(model.path)
      }

      folderModel.folder = model.path
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
        name: model.isFile ? getIcon(model.name) : 'folder-symbolic'
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

  ListModel {
    id: folderModel
    property string rootFolder: QmlJs.getNormalPath(homeDir)
    property string folder: rootFolder

    onFolderChanged: load()
    Component.onCompleted: {
      py.readyChanged.connect(function() {
        folderModel.load()
      })
    }

    function _abSort(a, b) {
      if (!a.isFile && b.isFile) { return -1 }
      if (a.isFile && !b.isFile) { return 1 }

      var aName = a.name.toLowerCase()
      var bName = b.name.toLowerCase()
      if (aName < bName) { return -1 }
      if (aName > bName) { return 1 }
      return 0
    }
    function getDirPath() {
      return folder.toString().replace('file://', '')
    }
    function getPrintableDirPath() {
      return QmlJs.getPrintableDirPath(folder.toString(), homeDir)
    }
    function load() {
      if (!py.ready) {
        return
      }

      clear()
      py.listDir(folder, function(entries) {
        console.log(folder, rootFolder)
        if (folder !== rootFolder) {
          append({
            name: '..',
            path: folder.split('/').slice(0, -1).join('/'),
            isFile: false
          })
        }
        entries
          .sort(_abSort)
          .forEach(function (entry) {
            append(entry)
          })
      })
    }
  }
  
  Python {
    id: py
    property bool ready: false

    Component.onCompleted: {
      // Print version of plugin and Python interpreter
      console.log('PyOtherSide version: ' + pluginVersion());
      console.log('Python version: ' + pythonVersion());
      addImportPath(Qt.resolvedUrl('../../py-backend'));
      importModule('fs_model', function() {
        ready = true
      });
    }

    function listDir(path, callback) {
      py.call('fs_model.list_dir', [path], callback);
    }
  }

  function getIcon(fileName) {
    var match = fileName.match(/\.([A-Za-z]+)$/)
    var ext = match && match[1]
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
