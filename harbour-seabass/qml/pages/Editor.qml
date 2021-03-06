import QtQuick 2.2

import QtWebKit 3.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

import '../generic/utils.js' as QmlJs
import '../components' as PlatformComponents
import '../generic' as GenericComponents

Page {
    id: page
    property string seabassFilePath

    allowedOrientations: Orientation.All

    GenericComponents.EditorApi {
        id: api

        // UI theme
        isDarkTheme: Theme.colorScheme === Theme.LightOnDark
        backgroundColor: isDarkTheme
            ? 'rgba(0, 0, 0, 0.75)'
            : 'rgba(255, 255, 255, 0.75)'
        foregroundColor: isDarkTheme
            ? 'rgba(0, 0, 0, 1)'
            : 'rgba(255, 255, 255, 1)'
        textColor: Theme.highlightColor
        linkColor: Theme.primaryColor

        // platform-specific i18n implementation for Generic API
        readErrorMsg: qsTr('Unable to read file. Please ensure that you have read access to the %1')
        writeErrorMsg: qsTr('Unable to write the file. Please ensure that you have write access to %1')

        // API methods
        onAppLoaded: function (data) {
            toolbar.open = data.isSailfishToolbarOpened || false
        }
        onErrorOccured: function (message) {
            displayError(message)
        }
        onIsReadOnlyChanged: {
            if (isReadOnly) {
                Qt.inputMethod.hide()
            }
        }
        onMessageSent: function(jsonMessage) {
            webView.experimental.postMessage(jsonMessage)
        }
        onFilePathChanged: {
            seabassFilePath = filePath
        }
    }

    Component.onCompleted: {
        const tmpHtmlFile = StandardPaths.temporary + '/harbour-seabas__cached-index.html'
        QmlJs.readFile(Qt.resolvedUrl('../html/index.html'), function(err, html) {
            QmlJs.writeFile(tmpHtmlFile, html.replace(/\$\{DEVICE_SCALE\}/g, getDeviceScale()), function(err) {
                if (err) {
                    return displayError(err.message)
                }

                webView.url = tmpHtmlFile
            })
        })
    }

    onOrientationChanged: fixResize()

    SilicaWebView {
        id: webView

        anchors.top: page.top
        anchors.bottom: toolbar.open ? toolbar.top : page.bottom
        width: page.width

        experimental.transparentBackground: true
        experimental.preferences.navigatorQtObjectEnabled: true
        experimental.onMessageReceived: {
            var msg = JSON.parse(message.data)
            // automatically copy selected text to the Clipboard
            if (msg.data && msg.data.selectedText) {
                Clipboard.text = msg.data.selectedText
            }

            api.handleMessage(msg.action, msg.data)
        }

        onNavigationRequested: function(request) {
            const urlStr = request.url.toString()
            const isHttpRequest = urlStr.indexOf('http') === 0
            if (!isHttpRequest) {
                return
            }

            request.action = WebView.IgnoreRequest;
            Qt.openUrlExternally(request.url)
        }

        PullDownMenu {
            busy: api.isSaveInProgress
            MenuItem {
                text: qsTr("Open file...")
                onClicked: {
                    api.hasChanges
                        ? pageStack.push(Qt.resolvedUrl('SaveDialog.qml'), {
                              filePath: api.filePath,
                              acceptDestination: filePickerPage,
                              acceptDestinationAction: PageStackAction.Replace
                          })
                        : pageStack.push(filePickerPage)
                }
            }
            MenuItem {
                enabled: !api.isSaveInProgress
                visible: api.filePath && !api.isReadOnly
                text: api.isSaveInProgress ? qsTr("Saving...") : qsTr("Save")
                onClicked: api.requestSaveFile()
            }
        }

        PushUpMenu {
            MenuItem {
                text: qsTr(toolbar.open ? "Hide toolbar" : "Show toolbar")
                onClicked: toolbar.open = !toolbar.open
            }
            MenuItem {
                text: qsTr('About')
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
        }
    }

    DockedPanel {
        id: toolbar
        dock: Dock.Bottom
        width: parent.width
        height: Theme.itemSizeMedium
        focus: false
        open: false
        onOpenChanged: {
            api.postMessage('setPreferences', {
                isSailfishToolbarOpened: open
            })
        }

        PlatformComponents.Toolbar {
            hasUndo: api.hasUndo
            hasRedo: api.hasRedo
            readOnly: api.isReadOnly
            readOnlyEnabled: !api.forceReadOnly

            onUndo: api.postMessage('undo')
            onRedo: api.postMessage('redo')
            onToggleReadOnly: api.postMessage('toggleReadOnly')
            onNavigateDown: api.postMessage('keyDown', { keyCode: 40 /* DOWN */ })
            onNavigateUp: api.postMessage('keyDown', { keyCode: 38 /* UP */ })
            onNavigateLeft: api.postMessage('keyDown', { keyCode: 37 /* LEFT */ })
            onNavigateRight: api.postMessage('keyDown', { keyCode: 39 /* RIGHT */ })
            onNavigateLineStart: api.postMessage('navigate', { where: 'lineStart' })
            onNavigateLineEnd: api.postMessage('navigate', { where: 'lineEnd' })
            onNavigateFileStart: api.postMessage('navigate', { where: 'fileStart' })
            onNavigateFileEnd: api.postMessage('navigate', { where: 'fileEnd' })
        }
    }

    Component {
        id: filePickerPage
        FilePickerPage {
            onSelectedContentPropertiesChanged: {
                if (!selectedContentProperties.filePath) {
                    return
                }

                if (api.filePath) {
                    api.closeFile(api.filePath)
                }
                api.loadFile(selectedContentProperties.filePath, false, Function.prototype)
                api.openFile(selectedContentProperties.filePath)
            }
        }
    }

    /**
     * Displays error message
     * @param {string} [errorMessage] - error message to display
     * @returns {undefined}
     */
    function displayError(errorMessage) {
        pageStack.completeAnimation()
        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {
            "text": errorMessage || error.message
        })
    }

    function getDeviceScale() {
        return Theme.pixelRatio * (540 / 320)
    }

    /**
     * Simple hak to fix issue with WebView not resized properly automatically when changing device orientation.
     * @returns {undefined}
     */
    function fixResize() {
        page.x = 1
        page.x = 0
    }
}
