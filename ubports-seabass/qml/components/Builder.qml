
import QtQuick 2.9
import io.thp.pyotherside 1.4

import "../generic/utils.js" as QmlJs

QtObject {
  id: root
  property bool ready: false
  property var onStdout: function() {}

  signal unhandledError(string message)

  property var py: Python {
    Component.onCompleted: {
      addImportPath(Qt.resolvedUrl('../../py-backend'))
      importModule('build_utils', function() {
        ready = true
      })
    }
    onReceived: function(lines) {
      onStdout(lines)
    }
    onError: function(pyErrorMessage) {
      unhandledError(pyErrorMessage)
    }
  }

  function build(config, onStdout, callback) {
    if (!ready) {
      return
    }

    ready = false
    root.onStdout = onStdout
    py.call('build_utils.build', [config], function(res) {
      ready = true
      root.onStdout = function() {}
      callback(res.error, res.result)
    })
  }

  function testContainer(callback) {
    py.call('build_utils.test_container_exists', [], function(res) {
      callback(res.error, res.result)
    })
  }
}


