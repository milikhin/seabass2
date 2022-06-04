import QtQuick 2.0
import './utils.js' as QmlJs

import io.thp.pyotherside 1.4

QtObject {
    id: api

    // operate in readonly mode if true, in readwrite mode otherwise
    property bool forceReadOnly: false
    property bool hasChanges: false
    property bool hasUndo: false
    property bool hasRedo: false
    property bool isDarkTheme: false
    property bool isReadOnly: false
    property bool isLoaded: false
    // true when the file is being saved
    property bool isSaveInProgress: false
    property string readErrorMsg: 'Unable to read file %1'
    property string writeErrorMsg: 'Unable to write file %1'
    property string backgroundColor
    property string borderColor
    property string textColor
    property string linkColor
    property string foregroundColor: backgroundColor
    property string foregroundTextColor: textColor
    property string homeDir
    property int fontSize: 12
    property int verticalHtmlOffset: 0
    property bool useWrapMode: true

    readonly property var py: Python {
      property bool ready: false

      Component.onCompleted: {
        addImportPath(Qt.resolvedUrl('../py-backend'))
        addImportPath(Qt.resolvedUrl('../../py-backend'))
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

    signal appLoaded(var preferences)
    signal messageSent(string jsonPayload)
    signal errorOccured(string message)

    Component.onCompleted: {
        appLoaded.connect(startup)
        isDarkThemeChanged.connect(loadTheme)
        linkColorChanged.connect(loadTheme)
        textColorChanged.connect(loadTheme)
        fontSizeChanged.connect(loadTheme)
        useWrapModeChanged.connect(loadTheme)
        verticalHtmlOffsetChanged.connect(loadTheme)
    }

    /**
     * Loads file at `filePath` into the editor.
     * It is possible to create file if not exists.
     * @returns {undefined}
     */
    function loadFile(filePath, readOnly, createIfNotExtist, doNotActivate, callback) {
      py.getEditorConfig(filePath, function(err, editorConfig) {
        if (err) {
          return callback(err)
        }

        QmlJs.readFile(filePath, function(err, text) {
          if (!err) {
            __load(filePath, editorConfig, readOnly, text)
            return callback(null, false)
          }

          if (!createIfNotExtist) {
            return callback(err)
          }

          QmlJs.writeFile(filePath, '', function(err) {
            if (err) {
              errorOccured(writeErrorMsg.arg(filePath))
              return callback(err)
            }

            __load(filePath, editorConfig, false, '')
            return callback(null, true)
          })
        })
      })

      function __load(filePath, editorConfig, readOnly, content) {
        postMessage('loadFile', {
          filePath: filePath,
          editorConfig: editorConfig,
          readOnly: readOnly,
          content: content,
          doNotActivate: doNotActivate
        })
      }
    }

    function openFile(filePath) {
      postMessage('openFile', {
        filePath: filePath
      })
    }

    function closeFile(filePath) {
      postMessage('closeFile', {
        filePath: filePath
      })
    }

    function oskVisibilityChanged(isVisible) {
      postMessage('oskVisibilityChanged', {
        isVisible: isVisible
      })
    }

    /**
     * Request editor to save file at the `filePath` (editor will reply with a message containing file content)
     * @returns {undefined}
     */
    function requestFileSave(filePath) {
        isSaveInProgress = true
        postMessage('requestFileSave', {
            filePath: filePath
        })
    }

    /**
     * Saves file with the given content at the given path
     * @param {string} filePath - /path/to/file
     * @param {string} content  - file content
     * @param {function} [callback]  - callback
     * @returns {undefined}
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

    function loadTheme() {
        postMessage('setPreferences', {
            isDarkTheme: isDarkTheme,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            highlightColor: linkColor,
            foregroundColor: foregroundColor,
            foregroundTextColor: foregroundTextColor,
            textColor: textColor,
            fontSize: fontSize,
            useWrapMode: useWrapMode,
            verticalHtmlOffset: verticalHtmlOffset
        })
    }

    function startup() {
        loadTheme()
    }

    /**
     * Handles incoming API message
     * @param {Object} message - API message
     * @returns {undefined}
     */
    function handleMessage(action, data) {
        switch (action) {
            case 'log':
                return console.log(JSON.stringify(data))
            case 'error':
                console.error(data.message)
                return errorOccured(data.message || 'unknown error')
            case 'appLoaded':
                api.isLoaded = true
                return appLoaded(data)
            case 'stateChanged':
                hasChanges = !data.isReadOnly && data.hasChanges
                hasUndo = !data.isReadOnly && data.hasUndo
                hasRedo = !data.isReadOnly && data.hasRedo
                isReadOnly = data.isReadOnly
                return
            case 'saveFile':
                return saveFile(data.filePath, data.content)
        }
    }

    /**
     * Sends API message
     * @param {string} action - API action name
     * @param {Object} data - action params
     * @returns {undefined}
     */
    function postMessage(action, data) {
        messageSent(JSON.stringify({ 'action': action, 'data': data || {}}));
    }
}
