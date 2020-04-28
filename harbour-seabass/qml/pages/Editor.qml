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
            MenuItem {
                text: qsTr("Open...")
                onClicked: pageStack.push(filePickerPage)
            }
            MenuItem {
                visible: webView.seabassFileName !== ''
                text: qsTr("Save")
                onClicked: saveFile()
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
                icon.source: "image://theme/icon-m-folder"
                onClicked: pageStack.push(filePickerPage)
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
    // #region JS_FUNCTIONS

    function openFile(fileName, filePath) {
        QmlJs.readFile(filePath, function(err, text) {
            if (err) {
                return console.error(err)
            }

            webView.seabassFileName = fileName
            webView.seabassFilePath = filePath
            editorApi('loadFile', {
                filePath: filePath,
                content: text
            })
        })
    }

    function saveFile() {
        editorApi('requestSaveFile', {
            filePath: webView.seabassFilePath
        })
    }

    function editorApiHandler(message) {
        switch (message.action) {
            case 'error':
                console.error(JSON.stringify(message))
                return

            case 'saveFile':
                return QmlJs.writeFile(message.data.filePath, message.data.content, function(err) {
                    if (err) {
                        console.error(err)
                    }
                })
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

    // WebView is not resize properly automatically when changing device orientation.
    // Simple hak to fix it
    function fixResize() {
        webView.x = 1
        webView.x = 0
    }

    // #endregion JS_FUNCTIONS
}
