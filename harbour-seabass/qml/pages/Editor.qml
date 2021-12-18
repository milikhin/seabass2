import QtQuick 2.2

import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.WebView 1.0

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
            ? 'rgba(0, 0, 0, 1)'
            : 'rgba(255, 255, 255, 1)'
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
        onMessageSent: function(jsonPayload) {
            viewFlickable.webView.runJavaScript("window.postSeabassApiMessage(" + jsonPayload + ")");
        }
        onFilePathChanged: {
            seabassFilePath = filePath
        }
    }

    WebViewFlickable {
        id: viewFlickable
        anchors.fill: parent
        webView.url: '../html/index.html'
        webView.viewportHeight: getEditorHeight()
        webView.opacity: api.filePath ? 1 : 0.75
        webView.onViewInitialized: {
            webView.loadFrameScript(Qt.resolvedUrl("../html/framescript.js"));
            webView.addMessageListener("webview:action")
        }
        webView.onRecvAsyncMessage: {
            switch (message) {
                case "webview:action": {
                    api.handleMessage(data.action, data.data)
                }
            }
        }
        webView.onLinkClicked: function(url) {
            Qt.openUrlExternally(url)
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
                onNavigateLineStart: api.postMessage('navigate', { where: 'LineStart' })
                onNavigateLineEnd: api.postMessage('navigate', { where: 'LineEnd' })
                onNavigateFileStart: api.postMessage('navigate', { where: 'DocStart' })
                onNavigateFileEnd: api.postMessage('navigate', { where: 'DocEnd' })
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

                if (api.filePath) {
                    api.closeFile(api.filePath)
                }
                api.loadFile(selectedContentProperties.filePath, false, true, false, Function.prototype)
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

    function getEditorHeight() {
        const dockHeight = toolbar.open ? toolbar.height : 0
        const windowHeight = page.orientation & Orientation.PortraitMask
            ? Screen.height
            : Screen.width
        const keyboardHeight = Qt.inputMethod.visible
            ? Qt.inputMethod.keyboardRectangle.height
            : 0
        return windowHeight - dockHeight - keyboardHeight
    }
}
