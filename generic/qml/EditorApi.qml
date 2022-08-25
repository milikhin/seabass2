import QtQuick 2.0
import './utils.js' as QmlJs

import io.thp.pyotherside 1.4

QtObject {
  id: api

  property bool isLoaded: false
  property bool isSaveInProgress: false
  property string homeDir
  property string readErrorMsg: 'Unable to read file %1'
  property string writeErrorMsg: 'Unable to write file %1'

  readonly property var py: Python {
    property bool ready: false

    Component.onCompleted: {
      addImportPath(Qt.resolvedUrl('../py-backend'))
      importModule('fs_utils', function() {
        ready = true
      });
    }

    function getEditorConfig(path, callback) {
      py.call('fs_utils.get_editor_config', [path], function(res) {
        callback(res.error, res.result)
      });
    }
  }

  onAppLoaded: {
    isLoaded = true
  }

  signal appLoaded(var preferences)
  signal messageSent(string jsonPayload)
  signal errorOccured(string message)
  signal stateChanged(var state)
  signal fileOpened(string filePath)
  signal fileBeingClosed(string filePath)

  /**
   * Loads file at `filePath` into the editor.
   * It is possible to create file if not exists.
   * @param {Object} options                   file options
   * @param {string} options.filePath          full file path
   * @param {Object} options.createIfNotExists automatically create new file if not exists
   */
  function loadFile(options) {
    const callback = options.callback || function() {}
    py.getEditorConfig(options.filePath, function(err, editorConfig) {
      if (err) {
        return callback(err)
      }

      QmlJs.readFile(options.filePath, function(err, fileContent) {
        if (!err) {
            __load(options.filePath, editorConfig, fileContent)
            return callback(null)
        }

        if (!options.createIfNotExists) {
            return callback(err)
        }

        QmlJs.writeFile(options.filePath, '', function(err) {
            if (err) {
            errorOccured(writeErrorMsg.arg(options.filePath))
            return callback(err)
            }

            __load(options.filePath, editorConfig, '')
            return callback(null)
        })
      })
    })

    function __load(filePath, editorConfig, content) {
      postMessage('loadFile', {
        filePath: filePath,
        editorConfig: editorConfig,
        content: content
      })
    }
  }

  /** Shows existing tab with given file */
  function openFile(filePath) {
    postMessage('openFile', { filePath: filePath })
  }

  /** Closes existing tab with given file */
  function closeFile(filePath) {
    postMessage('closeFile', { filePath: filePath })
  }

  /** Notifies HTML application of on-screen keyboard's visibility status changes */
  function oskVisibilityChanged(isVisible) {
    postMessage('oskVisibilityChanged', { isVisible: isVisible })
  }

  /**
   * Request editor to save given file
   * (editor should then reply with a message containing file content)
   */
  function requestFileSave(filePath) {
    isSaveInProgress = true
    postMessage('requestFileSave', { filePath: filePath })
  }

  function requestSaveAndClose(filePath) {
    isSaveInProgress = true
    postMessage('requestSaveAndClose', { filePath: filePath })
  }

  /**
   * Writes given content to the given path
   * @param {string} filePath     /path/to/file
   * @param {string} content      file content
   * @param {function} [callback] callback
   */
  function saveFile(filePath, content, callback) {
    callback = callback || function emptyCallback() {}
    isSaveInProgress = true
    return QmlJs.writeFile(filePath, content, function(err) {
      isSaveInProgress = false
      if (err) {
        console.error(err)
        errorOccured(writeErrorMsg.arg(filePath))
        return callback(err)
      }

      postMessage('fileSaved', { filePath: filePath })
      return callback(null)
    })
  }

  /**
    * Handles incoming API message
    * @param {Object} message - API message
    */
  function handleMessage(action, data) {
    switch (action) {
      case 'log':
        return console.log(JSON.stringify(data))
      case 'error':
        console.error(data.message)
        return errorOccured(data.message || 'unknown error')
      case 'appLoaded':
        return appLoaded(data)
      case 'stateChanged':
        return stateChanged(data)
      case 'saveFile':
        return saveFile(data.filePath, data.content)
      case 'saveAndClose':
        return saveFile(data.filePath, data.content, function(err) {
          if (err === null) {
            fileBeingClosed(data.filePath)
          }
        })
    }
  }

  /**
    * Sends API message
    * @param {string} action - API action name
    * @param {Object} data - action params
    */
  function postMessage(action, data) {
    const message = {
      action: action,
      data: data || {}
    }
    messageSent(JSON.stringify(message));
  }
}
