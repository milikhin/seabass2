import QtQuick 2.9
import io.thp.pyotherside 1.4

import "../../generic/utils.js" as QmlJs

Item {
  property string rootDirectory
  property string directory
  property string prevDirectory
  property bool showDotDot: false
  property var expanded: []
  property var prevExpanded: []

  signal errorOccured(string error)

  readonly property var model: ListModel {
    Component.onCompleted: {
      prevDirectory = directory
      directoryChanged.connect(reload)
      showDotDotChanged.connect(reload)
      py.readyChanged.connect(load)
    }
  }

  readonly property var py: Python {
    property bool ready: false
    onReceived: function(evtArgs) {
      if (evtArgs[0] !== 'fs_event') {
        return
      }

      load()
    }

    Component.onCompleted: {
      addImportPath(Qt.resolvedUrl('../../../py-backend'))
      importModule('fs_utils', function() {
        ready = true
      });
    }

    function listDir(path, expanded, callback) {
      const directories = [path].concat(expanded)
      py.call('fs_utils.list_files', [directories], function(res) {
        callback(res.error, res.result)
      });
      py.call('fs_utils.watch_changes', [directories]);
    }
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

    py.listDir(directory, expanded, function(error, entries) {
      if (error) {
        directory = prevDirectory
        // copy prevExpanded values
        expanded = [].concat(prevExpanded)
        return errorOccured(error)
      }
      const hasDotDot = showDotDot && directory !== rootDirectory
      if (hasDotDot) {
        model.set(0, {
          name: '..',
          path: QmlJs.getDirPath(QmlJs.getNormalPath(directory)) + '/',
          isDir: true
        })
      }
      const startIndex = hasDotDot ? 1 : 0
      const totalEntriesNumber = entries.length + startIndex
      entries.forEach(function (fileEntry, i) {
        var index = startIndex + i
        fileEntry.isExpanded = expanded.indexOf(fileEntry.path) !== -1
        if (index < model.count) {
          model.set(index, fileEntry)
        } else {
          model.append(fileEntry)
        }
      })
      if (totalEntriesNumber < model.count) {
        model.remove(totalEntriesNumber, model.count - totalEntriesNumber)
      }
      prevDirectory = directory
      // copy expanded values
      prevExpanded = [].concat(expanded)
    })
  }
  function reload() {
    expanded = []
    load()
  }
  function toggleExpanded(path) {
    if (expanded.indexOf(path) === -1) {
      expanded.push(path)
    } else {
      var newExpanded = []
      expanded.forEach(function(expandedPath) {
        if (expandedPath.indexOf(path) !== 0) {
          newExpanded.push(expandedPath)
        }
      })
      expanded = newExpanded
    }

    load()
  }
}
