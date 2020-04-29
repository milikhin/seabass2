import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import '../utils.js' as QmlJs

Page {
    id: page

    property string seabassFileName: ''
    property string seabassFilePath: ''
    property bool seabassIsReadOnly: true
    property bool seabassHasUndo: false
    property bool seabassHasRedo: false
    property bool seabassIsSaveInProgress: false

    allowedOrientations: Orientation.All
    onOrientationChanged: {
        webView.experimental.deviceWidth = getDeviceWidth()
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

        VerticalScrollDecorator {}
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
        }
    }

    DockedPanel {
        id: panel

        width: parent.width
        height: Theme.itemSizeMedium
        dock: Dock.Bottom
        focus: false

        Flow {
            anchors.leftMargin: Theme.paddingMedium
            anchors.left: isPortrait ? parent.left: undefined
            anchors.verticalCenter: isPortrait ? parent.verticalCenter: undefined

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
            page.seabassIsReadOnly = readOnly || false

            editorApi('loadFile', {
                filePath: filePath,
                content: text,
                readOnly: page.seabassIsReadOnly
            })
        })
    }

    function requestSaveFile() {
        setSaveInProgress(true)
        editorApi('requestSaveFile')
    }

    // #endregion UI_ACTIONS
    // #endregion JS_FUNCTIONS

    function displayError(error, errorMessage) {
        console.error(error)
        pageStack.completeAnimation()
        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {
            "text": errorMessage || error.message
        })
    }

    function editorApiHandler(message) {
        if (message.data && message.data.responseTo === 'requestSaveFile') {
            setSaveInProgress(false)
        }

        switch (message.action) {
            case 'error':
                return displayError(null, message.data.errorMessage || 'unknown error')
            case 'appLoaded':
                const welcomeNoteUrl = Qt.resolvedUrl("../changelog.txt")
                return openFile('changelog.txt', welcomeNoteUrl, true)
            case 'stateChanged':
                if (message.data.filePath === page.seabassFilePath) {
                    page.seabassHasUndo = message.data.hasUndo
                    page.seabassHasRedo = message.data.hasRedo
                }

                return
            case 'saveFile':
                return saveFile(message.data.filePath, message.data.content)
        }
    }

    function editorApi(action, data) {
        data = data || {}
        if (!data.filePath) {
            data.filePath = page.seabassFilePath
        }

        webView.experimental.postMessage(JSON.stringify({ 'action': action, 'data': data }));
    }

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

    function getDeviceWidth() {
        const deviceWidth = page.orientation === Orientation.Portrait
            ? Screen.width
            : Screen.height
        return deviceWidth / Theme.pixelRatio / (540 / 320)
    }

    function setSaveInProgress(saveInProgress) {
        page.seabassIsSaveInProgress = saveInProgress
    }

    // WebView is not resize properly automatically when changing device orientation.
    // Simple hak to fix it
    function fixResize() {
        webView.x = 1
        webView.x = 0
    }

    // #endregion JS_FUNCTIONS
}
