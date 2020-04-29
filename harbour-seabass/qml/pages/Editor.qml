import QtQuick 2.2
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import '../utils.js' as QmlJs

Page {
    id: page
    allowedOrientations: Orientation.All
    onOrientationChanged: {
        webView.experimental.deviceWidth = getDeviceWidth()
        fixResize()
    }

    // #region LAYOUT

    SilicaWebView {
        id: webView
        url: '../html/index.html'

        property string seabassFileName: ''
        property string seabassFilePath: ''
        property bool seabassIsReadOnly: true
        property bool seabassIsSaveInProgress: false

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
            busy: webView.seabassIsSaveInProgress
            MenuItem {
                text: qsTr("Open file...")
                onClicked: pageStack.push(filePickerPage)
            }
            MenuItem {
                enabled: !webView.seabassIsSaveInProgress
                visible: webView.seabassFileName !== ''
                text: webView.seabassIsSaveInProgress ? qsTr("Saving...") : qsTr("Save")
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
                icon.source: "image://theme/icon-m-back"
                onClicked: editorApi('undo')
            }

            IconButton {
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

    function openFile(fileName, filePath) {
        QmlJs.readFile(filePath, function(err, text) {
            if (err) {
                return displayError(err,
                    qsTr('Unable to read file. Please ensure that you have read access to the') + ' ' + filePath)
            }

            webView.seabassFileName = fileName
            webView.seabassFilePath = filePath
            editorApi('loadFile', {
                filePath: filePath,
                content: text
            })
        })
    }

    function requestSaveFile() {
        setSaveInProgress(true)
        editorApi('requestSaveFile', {
            filePath: webView.seabassFilePath
        })
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

    function editorApiHandler(message) {
        if (message.data && message.data.responseTo === 'requestSaveFile') {
            setSaveInProgress(false)
        }

        switch (message.action) {
            case 'error':
                return displayError(null, message.data.errorMessage || 'unknown error')
            case 'saveFile':
                return saveFile(message.data.filePath, message.data.content)
        }
    }

    function editorApi(action, data) {
        webView.experimental.postMessage(JSON.stringify({ 'action': action, 'data': data }));
    }

    function getDeviceWidth() {
        const deviceWidth = page.orientation === Orientation.Portrait
            ? Screen.width
            : Screen.height
        return deviceWidth / Theme.pixelRatio / (540 / 320)
    }

    function setSaveInProgress(saveInProgress) {
        webView.seabassIsSaveInProgress = saveInProgress
    }

    // WebView is not resize properly automatically when changing device orientation.
    // Simple hak to fix it
    function fixResize() {
        webView.x = 1
        webView.x = 0
    }

    // #endregion JS_FUNCTIONS
}
