import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import '../utils.js' as QmlJs

Page {
    id: page

    property string seabassFileName: ''
    property string seabassFilePath: ''
    property bool seabassForceReadOnly: false
    property bool seabassIsReadOnly: false
    property bool seabassHasUndo: false
    property bool seabassHasRedo: false
    property bool seabassIsSaveInProgress: false

    allowedOrientations: Orientation.All
    onOrientationChanged: {
        fixResize()
    }

    // #region LAYOUT

    SilicaWebView {
        id: webView
        url: '../html/index.html'

        anchors.top: page.top
        anchors.bottom: panel.open ? panel.top : page.bottom
        width: page.width

        experimental.onMessageReceived: {
            var msg = JSON.parse(message.data)
            editorApiHandler(msg)
        }
        experimental.transparentBackground: true
        experimental.deviceWidth: getDeviceWidth()
        experimental.preferences.navigatorQtObjectEnabled: true

        PullDownMenu {
            busy: page.seabassIsSaveInProgress
            MenuItem {
                text: qsTr("Open file...")
                onClicked: pageStack.push(filePickerPage)
            }
            MenuItem {
                enabled: !page.seabassIsSaveInProgress
                visible: !page.seabassIsReadOnly
                text: page.seabassIsSaveInProgress ? qsTr("Saving...") : qsTr("Save")
                onClicked: requestSaveFile()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr(panel.open ? "Hide toolbar" : "Show toolbar")
                onClicked: panel.open = !panel.open
            }
            MenuItem {
                text: qsTr('About')
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }
    }

    DockedPanel {
        id: panel

        width: parent.width
        height: Theme.itemSizeMedium
        dock: Dock.Bottom
        focus: false

        SilicaFlickable {
            contentWidth: panelRow.childrenRect.width;
            height: parent.height
            width: parent.width

            HorizontalScrollDecorator {}
            flickableDirection: Flickable.HorizontalFlick

            Row {
                id: panelRow
                anchors.verticalCenter: parent.verticalCenter

                IconButton {
                    enabled: page.seabassHasUndo
                    icon.source: "image://theme/icon-m-back"
                    onClicked: editorApi('undo')
                }

                IconButton {
                    enabled: page.seabassHasRedo
                    icon.source: "image://theme/icon-m-forward"
                    onClicked: editorApi('redo')
                }

                IconButton {
                    icon.source: "image://theme/icon-m-left"
                    onClicked: editorApi('navigateLeft')
                }

                IconButton {
                    icon.source: "image://theme/icon-m-right"
                    onClicked: editorApi('navigateRight')
                }

                IconButton {
                    icon.source: "image://theme/icon-m-up"
                    onClicked: editorApi('navigateUp')
                }

                IconButton {
                    icon.source: "image://theme/icon-m-down"
                    onClicked: editorApi('navigateDown')
                }

                TextSwitch {
                    id: readOnlySwitch
                    text: "Read only"
                    width: childrenRect.width + Theme.paddingLarge
                    enabled: !page.seabassForceReadOnly
                    checked: page.seabassIsReadOnly
                    onClicked: editorApi('toggleReadOnly')
                    Component.onCompleted: {
                        var label = children[1]
                        var description = children[2]
                        label.width = undefined
                        description.width = 0
                        description.visible = 0
                    }
                }
            }
        }
    }

    Component {
        id: filePickerPage
        FilePickerPage {
            onSelectedContentPropertiesChanged: {
                if (!selectedContentProperties.filePath) {
                    return
                }

                openFile(selectedContentProperties.fileName, selectedContentProperties.filePath)
            }
        }
    }

    // #endregion LAYOUT
    // #region UI_ACTIONS

    /**
     * Opens given file in the editor
     * @param {string} fileName  - file name
     * @param {string} filePath - /path/to/file
     * @param {boolean} [readOnly=false] - open file in readonly mode if true, in readwrite mode otherwise
     * @returns {undefined}
     */
    function openFile(fileName, filePath, readOnly) {
        QmlJs.readFile(filePath, function(err, text) {
            if (err) {
                return displayError(err,
                    qsTr('Unable to read file. Please ensure that you have read access to the') + ' ' + filePath)
            }

            page.seabassFileName = fileName
            page.seabassFilePath = filePath
            page.seabassHasUndo = false
            page.seabassHasRedo = false
            page.seabassForceReadOnly = readOnly ||false

            editorApi('loadFile', {
                filePath: filePath,
                content: text,
                readOnly: page.seabassForceReadOnly
            })
        })
    }

    /**
     * Request editor to save file at the given path (editor will reply with a message containing file content)
     * @returns {undefined}
     */
    function requestSaveFile() {
        setSaveInProgress(true)
        editorApi('requestSaveFile')
    }

    // #endregion UI_ACTIONS
    // #endregion JS_FUNCTIONS

    /**
     * Displays error message
     * @param {Error} error - error object
     * @param {string} [errorMessage] - error message to display
     * @returns {undefined}
     */
    function displayError(error, errorMessage) {
        console.error(error)
        pageStack.completeAnimation()
        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {
            "text": errorMessage || error.message
        })
    }

    /**
     * Handles incoming API message
     * @param {Object} message - API message
     * @returns {undefined}
     */
    function editorApiHandler(message) {
        if (message.data && message.data.responseTo === 'requestSaveFile') {
            setSaveInProgress(false)
        }

        switch (message.action) {
            case 'error':
                return displayError(null, message.data.errorMessage || 'unknown error')
            case 'appLoaded':
                if (!seabassFilePath) {
                    return
                }
                var isWelcomeText = Qt.resolvedUrl("../changelog.txt") === seabassFilePath
                return openFile(seabassFileName, seabassFilePath, isWelcomeText)
            case 'stateChanged':
                if (message.data.filePath === page.seabassFilePath) {
                    page.seabassHasUndo = !message.data.isReadOnly && message.data.hasUndo
                    page.seabassHasRedo = !message.data.isReadOnly && message.data.hasRedo

                    if (message.data.isReadOnly && !page.seabassIsReadOnly) {
                        Qt.inputMethod.hide()
                    }

                    page.seabassIsReadOnly = message.data.isReadOnly
                    readOnlySwitch.checked = message.data.isReadOnly
                }

                return
            case 'saveFile':
                return saveFile(message.data.filePath, message.data.content)
        }
    }

    /**
     * Sends API message
     * @param {string} action - API action name
     * @param {Object} data - action params
     * @returns {undefined}
     */
    function editorApi(action, data) {
        data = data || {}
        if (!data.filePath) {
            data.filePath = page.seabassFilePath
        }

        webView.experimental.postMessage(JSON.stringify({ 'action': action, 'data': data }));
    }

    /**
     * Saves file with the given content at the given path
     * @param {string} filePath - /path/to/file
     * @param {string} content  - file content
     * @returns {undefined}
     */
    function saveFile(filePath, content) {
        setSaveInProgress(true)
        return QmlJs.writeFile(filePath, content, function(err) {
            setSaveInProgress(false)
            if (err) {
                return displayError(err,
                    qsTr('Unable to write the file. Please ensure that you have write access to') + ' ' + filePath)
            }
        })
    }

    /**
     * Returns HTML device-width scaled correctly for the current device
     * @returns {int} - device width in CSS pixels
     */
    function getDeviceWidth() {
        const deviceWidth = page.orientation === Orientation.Portrait
            ? Screen.width
            : Screen.height
        return deviceWidth / Theme.pixelRatio / (540 / 320)
    }

    /**
     * Sets saveInProgress flag
     * @param {boolean} saveInProgress - flag value
     * @returns {undefined}
     */
    function setSaveInProgress(saveInProgress) {
        page.seabassIsSaveInProgress = saveInProgress
    }

    /**
     * Simple hak to fix issue with WebView not resized properly automatically when changing device orientation.
     * @returns {undefined}
     */
    function fixResize() {
        webView.experimental.deviceWidth = getDeviceWidth()
        page.x = 1
        page.x = 0
    }

    // #endregion JS_FUNCTIONS
}
