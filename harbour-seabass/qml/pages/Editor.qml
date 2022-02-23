import QtQuick 2.2

import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.WebView 1.0

import '../generic/utils.js' as QmlJs
import '../components' as PlatformComponents
import '../generic' as GenericComponents

WebViewPage {
    id: page
    property string seabassFilePath
    property int headerHeight: 0
    allowedOrientations: Orientation.All

    GenericComponents.EditorApi {
        id: api
        homeDir: StandardPaths.home

        // UI theme
        isDarkTheme: Theme.colorScheme === Theme.LightOnDark
        backgroundColor: isDarkTheme ? QmlJs.colors.DARK_BACKGROUND : QmlJs.colors.LIGHT_BACKGROUND
        // default text color from Codemirror
        textColor: isDarkTheme ? QmlJs.colors.DARK_TEXT : QmlJs.colors.LIGHT_TEXT
        linkColor: textColor

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
        header: Rectangle {
            id: editorHeader
            color: api.backgroundColor
            height: childrenRect.height
            PageHeader {
                title: api.filePath ? QmlJs.getFileName(api.filePath) : 'Seabass v0.7.2'
                description: api.filePath
                    ? QmlJs.getPrintableDirPath(QmlJs.getDirPath(api.filePath), api.homeDir)
                    : 'Release notes'
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: api.isDarkTheme ? QmlJs.colors.DARK_DIVIDER : QmlJs.colors.LIGHT_DIVIDER
                height: api.filePath ? Theme.dp(1) : 0
            }

            Component.onCompleted: {
                headerHeight = height
            }
        }
        interactive: !Qt.inputMethod.visible
        webView.url: '../html/index.html'
        webView.viewportHeight: getEditorHeight()
        webView.opacity: 1
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
        Component.onCompleted: {
            Qt.inputMethod.visibleChanged.connect(function() {
                api.oskVisibilityChanged(Qt.inputMethod.visible)
            })
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
            background: Rectangle {
                color: api.isDarkTheme
                       ? QmlJs.colors.DARK_TOOLBAR_BACKGROUND
                       : QmlJs.colors.LIGHT_TOOLBAR_BACKGROUND
                // default background doesn't look good when virtual keyboard is opened
                // hence the workaround with Rectangle
            }

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
                onNavigateLineStart: api.postMessage('keyDown', { keyCode: 36 /* HOME */ })
                onNavigateLineEnd: api.postMessage('keyDown', { keyCode: 35 /* END */ })
                onNavigateFileStart: api.postMessage('keyDown', { keyCode: 33 /* Page UP */ })
                onNavigateFileEnd: api.postMessage('keyDown', { keyCode: 34 /* Page DOWN */ })
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
        return windowHeight - dockHeight - headerHeight
    }
}
