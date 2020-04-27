import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import '../utils.js' as QmlJs

Page {
    id: page
    property string fileName: ''
    property bool isReadOnly: true

    allowedOrientations: Orientation.All
    onOrientationChanged: function() {
        webView.experimental.deviceWidth = getDeviceWidth()
        fixResize()
    }

    SilicaWebView {
        id: webView
        url: '../html/index.html'

        anchors.top: page.top
        anchors.bottom: panel.open ? panel.top : page.bottom
        width: page.width

        experimental.onMessageReceived: {
            var msg = JSON.parse(message.data)
            QmlJs.handleApiMessage(msg)
        }
        experimental.transparentBackground: true
        experimental.deviceWidth: getDeviceWidth()
        experimental.preferences.navigatorQtObjectEnabled: true

        PullDownMenu {
            MenuItem {
                text: qsTr(panel.open ? "Hide toolbar" : "Show toolbar")
                onClicked: panel.open = !panel.open
            }
            MenuItem {
                text: qsTr("Open file...")
                onClicked: pageStack.push(filePickerPage)
            }

            MenuLabel {
                text: page.fileName
                visible: page.fileName !== ''
            }
            MenuItem {
                visible: page.fileName !== ''
                text: qsTr("Save")
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
            IconButton {
                icon.source: "image://theme/icon-m-accept"
                onClicked: editorApi('save')
            }
        }
    }

    Component {
        id: filePickerPage
            FilePickerPage {
                onSelectedContentPropertiesChanged: {
                    if (selectedContentProperties.filePath) {
                        loadFile(selectedContentProperties.fileName, selectedContentProperties.filePath)
                    }
                }
        }
    }

    function loadFile(fileName, filePath) {
        QmlJs.readFile(filePath, function(err, text) {
            if (err) {
                return console.error(err)
            }

            page.fileName = fileName
            editorApi('loadFile', {
                filePath: filePath,
                content: text
            })
        })
    }

    function editorApi(action, data) {
        webView.experimental.postMessage(JSON.stringify({ 'action': action, 'data': data }));
    }

    function getDeviceWidth() {
        console.log(Theme.pixelRatio)
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
}
