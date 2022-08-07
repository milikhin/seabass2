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
      directoryChanged.connect(reload)
      showDotDotChanged.connect(reload)
      py.readyChanged.connect(function() {
        load(true)
      })
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
      })
    }

    function listDir(path, expanded, callback) {
      const directories = [path].concat(expanded)
      py.call('fs_utils.list_files', [directories], function(res) {
        callback(res.error, res.result)
      })
      py.call('fs_utils.watch_changes', [directories])
    }
  }

  function guessFilePath(sourceApp, fileName, callback) {
    py.call('fs_utils.guess_file_path', [sourceApp, fileName], function(res) {
      callback(res.error, res.result)
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
  function getDirPath() {
    return directory.toString().replace('file://', '')
  }
  function getPrintableDirPath() {
    return QmlJs.getPrintableDirPath(directory.toString(), homeDir)
  }
  function load(ignoreError) {
    if (!py.ready) {
      return
    }

    py.listDir(directory, expanded, function(error, entries) {
      if (error) {
        directory = prevDirectory
        // copy prevExpanded values
        expanded = [].concat(prevExpanded)
        if (ignoreError) {
          return;
        }
        return errorOccured(error)
      }
      const hasDotDot = showDotDot && directory !== rootDirectory
      if (hasDotDot) {
        model.set(0, {
          name: '..',
          path: QmlJs.getDirPath(QmlJs.getNormalPath(directory)),
          isDir: true
        })
      }
      const startIndex = hasDotDot ? 1 : 0
      const totalEntriesNumber = entries.length + startIndex
      entries.forEach(function (fileEntry, i) {
        var index = startIndex + i
        fileEntry.isExpanded = expanded.indexOf(fileEntry.path) !== -1
        if (index < model.count) {
          // update non-last model entries
          model.set(index, fileEntry)
        } else {
          // append new model entries
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

  function rm(path, callback) {
    if (!py.ready) {
      return
    }

    py.call('fs_utils.rm', [path], function(res) {
      callback(res.error)
    })
  }

  function rename(originalPath, newPath, callback) {
    if (!py.ready) {
      return
    }

    py.call('fs_utils.rename', [originalPath, newPath], function(res) {
      callback(res.error)
    })
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
