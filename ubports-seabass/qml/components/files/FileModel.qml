import QtQuick 2.9
import io.thp.pyotherside 1.4

import "../../generic/utils.js" as QmlJs

Item {
  property string rootDirectory
  property string directory
  readonly property var expanded: []

  readonly property var model: ListModel {
    Component.onCompleted: {
      directoryChanged.connect(load)
      py.readyChanged.connect(load)
    }
  }
  readonly property var py: Python {
    property bool ready: false

    Component.onCompleted: {
      addImportPath(Qt.resolvedUrl('../../../py-backend'))
      importModule('fs_model', function() {
        ready = true
      });
    }

    function listDir(path, expanded, callback) {
      py.call('fs_model.list_dir', [path, expanded], callback);
    }
  }

  function getDirPath() {
    return directory.toString().replace('file://', '')
  }
  function getPrintableDirPath() {
    return QmlJs.getPrintableDirPath(directory.toString(), homeDir)
  }
  function load() {
    if (!py.ready) {
      return
    }

    model.clear()
    py.listDir(directory, expanded, function(entries) {
      if (directory !== rootDirectory) {
        model.append({
          name: '..',
          path: directory.split('/').slice(0, -1).join('/'),
          isDir: true
        })
      }
      entries
        .sort(QmlJs.sortFiles)
        .forEach(function (fileEntry) {
          model.append(fileEntry)
        })
    })
  }
  function toggleExpanded(path) {
    if (expanded.indexOf(path) === -1) {
      expanded.push(path)
    } else {
      expanded.splice(expanded.indexOf(path), 1)
    }

    load()
  }
}
