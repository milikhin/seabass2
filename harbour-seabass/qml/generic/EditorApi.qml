import QtQuick 2.0
import './utils.js' as QmlJs

QtObject {
    id: api

    // /path/to/file on the device
    property string filePath
    // operate in readonly mode if true, in readwrite mode otherwise
    property bool forceReadOnly: false
    property bool hasUndo: false
    property bool hasRedo: false
    property bool isDarkTheme: true
    property bool isReadOnly: false
    // true when the file is being saved
    property bool isSaveInProgress: false

    signal appLoaded(var preferences)
    signal messageSent(string jsonPayload)
    signal errorOccured(string message)

    Component.onCompleted: {
        isAppLoadedChanged.connect(startup)
        filePathChanged.connect(openFile)
        isDarkThemeChanged.connect(switchTheme)
    }

    /**
     * Opens file at `filePath` in the editor
     * @returns {undefined}
     */
    function openFile() {
        QmlJs.readFile(filePath, function(err, text) {
            if (err) {
                console.error(err)
                return errorOccured(qsTr('Unable to read file. Please ensure that you have read access to the') + ' ' + filePath)
            }

            postMessage('loadFile', {
                filePath: filePath,
                content: text,
                readOnly: forceReadOnly
            })
        })
    }

    /**
     * Request editor to save file at the `filePath` (editor will reply with a message containing file content)
     * @returns {undefined}
     */
    function requestSaveFile() {
        isSaveInProgress = true
        postMessage('requestSaveFile')
    }

    /**
     * Saves file with the given content at the given path
     * @param {string} filePath - /path/to/file
     * @param {string} content  - file content
     * @returns {undefined}
     */
    function saveFile(filePath, content) {
        isSaveInProgress = true
        return QmlJs.writeFile(filePath, content, function(err) {
            isSaveInProgress = false
            if (err) {
                return displayError(err,
                    qsTr('Unable to write the file. Please ensure that you have write access to') + ' ' + filePath)
            }
        })
    }

    function switchTheme() {
        postMessage('setPreferences', {
            isDarkTheme: isDarkTheme
        })
    }

    function startup() {
        switchTheme()
        if (filePath) {
            openFile()
        }
    }

    /**
     * Handles incoming API message
     * @param {Object} message - API message
     * @returns {undefined}
     */
    function handleMessage(action, data) {
        if (data && data.responseTo === 'requestSaveFile') {
            isSaveInProgress = false
        }

        switch (action) {
            case 'error':
                return errorOccured(data.message || 'unknown error')
            case 'appLoaded':
                return appLoaded(data)
            case 'stateChanged':
                if (data.filePath !== filePath) {
                    return
                }

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
        data = data || {}
        if (!data.filePath) {
            data.filePath = filePath
        }

        messageSent(JSON.stringify({ 'action': action, 'data': data }));
    }
}
