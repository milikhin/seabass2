import QtQuick 2.2

import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0

import '../generic/utils.js' as QmlJs
import '../components' as PlatformComponents
import '../generic' as GenericComponents

WebViewPage {
    id: page
    property int headerHeight: 0
    property bool isMenuEnabled: true
    property bool hasOpenedFile: editorState.filePath !== ''
    property alias filePath: editorState.filePath
    allowedOrientations: Orientation.All

    onIsMenuEnabledChanged: {
        if (isMenuEnabled) {
            hint.start()
        } else {
            hint.stop()
        }
    }

    background: Rectangle {
        color: editorState.isDarkTheme ? QmlJs.colors.DARK_BACKGROUND : QmlJs.colors.LIGHT_BACKGROUND
        height: page.height
        width: page.width
    }

    GenericComponents.EditorState {
        id: editorState
        isDarkTheme: Theme.colorScheme === Theme.LightOnDark
        verticalHtmlOffset: headerHeight / WebEngineSettings.pixelRatio

        onFilePathChanged: {
            isMenuEnabled = false
        }

        onDirectoryChanged: {
            api.postMessage('setSailfishPreferences', {
                directory: directory
            })
        }
    }

    GenericComponents.EditorApi {
        id: api
        homeDir: StandardPaths.home

        // platform-specific i18n implementation for Generic API
        readErrorMsg: qsTr('Unable to read file. Please ensure that you have read access to the %1')
        writeErrorMsg: qsTr('Unable to write the file. Please ensure that you have write access to %1')

        // API methods
        onAppLoaded: function (data) {
            toolbar.open = data.isToolbarOpened || false
            editorState.fontSize = data.fontSize
            editorState.useWrapMode = data.useWrapMode
            // use `data.directory || api.homeDir` to restore last opened directory when opening app
            editorState.directory = api.homeDir
            editorState.loadTheme()
            editorState.updateViewport()
        }

        onErrorOccured: function (message) {
            displayError(message)
        }

        onMessageSent: function(jsonPayload) {
            viewFlickable.webView.runJavaScript("window.postSeabassApiMessage(" + jsonPayload + ")");
        }

        onStateChanged: function(data) {
            editorState.hasChanges = !data.isReadOnly && data.hasChanges
            editorState.hasUndo = !data.isReadOnly && data.hasUndo
            editorState.hasRedo = !data.isReadOnly && data.hasRedo
            editorState.isReadOnly = data.isReadOnly
        }
    }

    WebViewFlickable {
        id: viewFlickable
        anchors.fill: parent
        header: PageHeader {
            page: page
            title: hasOpenedFile
                ? ((editorState.hasChanges ? '*' : '') + QmlJs.getFileName(filePath))
                : qsTr('Seabass v%1').arg('0.10.0')
            description: hasOpenedFile
                ? QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir)
                : qsTr('Release notes')

            onHeightChanged: {
                headerHeight = height
            }

            // Show divider between page header and editor when file is opened
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: editorState.isDarkTheme ? QmlJs.colors.DARK_DIVIDER : QmlJs.colors.LIGHT_DIVIDER
                height: hasOpenedFile ? Theme.dp(1) : 0
            }
        }

        webView.opacity: 1
        webView.url: '../html/index.html'
        webView.viewportHeight: getEditorHeight()

        Component.onCompleted: {
            Qt.inputMethod.visibleChanged.connect(function() {
                api.oskVisibilityChanged(Qt.inputMethod.visible)
            })
        }

        // Initialize API transport method for Sailfish OS
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

        // Open all the links externally in a browser
        webView.onLinkClicked: function(url) {
            Qt.openUrlExternally(url)
        }

        PullDownMenu {
            busy: api.isSaveInProgress
            visible: isMenuEnabled
            MenuItem {
                text: qsTr("Open file...")
                onClicked: {
                    if (!editorState.hasChanges) {
                        return pageStack.push(filePicker)
                    }

                    pageStack.push(Qt.resolvedUrl('SaveDialog.qml'), {
                        filePath: filePath,
                        acceptDestination: filePicker,
                        acceptDestinationAction: PageStackAction.Replace
                    })
                }
            }
            MenuItem {
                enabled: !api.isSaveInProgress && !editorState.isReadOnly
                visible: hasOpenedFile
                text: api.isSaveInProgress ? qsTr("Saving...") : qsTr("Save")
                onClicked: {
                    api.requestFileSave(filePath)
                }
            }
        }

        PushUpMenu {
            visible: isMenuEnabled
            MenuItem {
                text: toolbar.open ? qsTr("Hide toolbar") : qsTr("Show toolbar")
                onClicked: {
                    toolbar.open = !toolbar.open
                }
            }
            MenuItem {
                text: qsTr('Settings')
                onClicked: {
                    pageStack.push(settings)
                }
            }
            MenuItem {
                text: qsTr('About')
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("About.qml"))
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
            background: Rectangle {
                // default background doesn't look good when virtual keyboard is opened
                // hence the workaround with Rectangle
                color: editorState.isDarkTheme
                       ? QmlJs.colors.DARK_TOOLBAR_BACKGROUND
                       : QmlJs.colors.LIGHT_TOOLBAR_BACKGROUND
            }

            onOpenChanged: {
                api.postMessage('setSailfishPreferences', {
                    isToolbarOpened: open
                })
            }

            PlatformComponents.Toolbar {
                hasUndo: editorState.hasUndo
                hasRedo: editorState.hasRedo
                readOnly: editorState.isReadOnly
                readOnlyEnabled: hasOpenedFile

                onUndo: api.postMessage('undo')
                onRedo: api.postMessage('redo')
                onToggleReadOnly: api.postMessage('toggleReadOnly')
                onNavigateDown: api.postMessage('keyDown', { keyCode: 40 /* DOWN */ })
                onNavigateUp: api.postMessage('keyDown', { keyCode: 38 /* UP */ })
                onNavigateLeft: api.postMessage('keyDown', { keyCode: 37 /* LEFT */ })
                onNavigateRight: api.postMessage('keyDown', { keyCode: 39 /* RIGHT */ })
                onNavigateLineStart: api.postMessage('keyDown', { keyCode: 36 /* HOME */ })
                onNavigateLineEnd: api.postMessage('keyDown', { keyCode: 35 /* END */ })
                onNavigateFileStart: api.postMessage('keyDown', { keyCode: 36 /* HOME */, ctrlKey: true })
                onNavigateFileEnd: api.postMessage('keyDown', { keyCode: 35 /* END */, ctrlKey: true })
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: hasOpenedFile && isMenuEnabled
            onClicked: {
                if (hasOpenedFile) {
                    isMenuEnabled = false
                }
            }
        }

        // Floating action button to enable pulley menus
        PlatformComponents.FloatingButton {
            anchors.bottom: toolbar.open ? toolbar.top : parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            visible: hasOpenedFile

            isDarkTheme: editorState.isDarkTheme
            highlighed: isMenuEnabled
            icon.source: "image://theme/icon-m-gesture"
            onClicked: isMenuEnabled = !isMenuEnabled
        }

        TouchInteractionHint {
            id: hint
            direction: TouchInteraction.Down
        }
    }

    GenericComponents.TabsModel {
        id: tabsModel
        onTabAdded: function(tab) {
            api.loadFile({
                filePath: tab.filePath,
                createIfNotExists: true,
                callback: function(err) {
                    if (err) {
                        tabsModel.close(tab.filePath)
                    }
                    api.openFile(tab.filePath)
                }
            })
        }
        onTabClosed: function(tabId) {
            api.closeFile(tabId)
        }
    }

    Component {
        id: filePicker
        Files {
            homeDir: api.homeDir
            directory: editorState.directory
            onDirectoryChanged: {
                editorState.directory = directory
            }
            onOpened: function(filePath) {
                if (hasOpenedFile) {
                    tabsModel.close(editorState.filePath)
                }
                tabsModel.open({
                    id: filePath,
                    filePath: filePath,
                    subTitle: QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir),
                    title: QmlJs.getFileName(filePath)
                })
                editorState.filePath = filePath
            }
        }
    }

    Component {
        id: settings
        Settings {
            fontSize: editorState.fontSize
            useWrapMode: editorState.useWrapMode

            onFontSizeChanged: {
                editorState.fontSize = fontSize
            }
            onUseWrapModeChanged: {
                editorState.useWrapMode = useWrapMode
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
        const isPortrait = page.orientation & Orientation.PortraitMask
        const screenHeight = isPortrait
            ? Screen.height
            : Screen.width
        const keyboardHeight = isPortrait
            ? Qt.inputMethod.keyboardRectangle.height
            : Qt.inputMethod.keyboardRectangle.width
        const toolbarHeight = toolbar.open ? toolbar.height : 0
        return screenHeight - keyboardHeight - toolbarHeight
    }
}
