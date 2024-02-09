import QtQuick 2.2

import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0
import Sailfish.WebView 1.0
import Sailfish.WebEngine 1.0
import Nemo.Configuration 1.0

import '../generic/utils.js' as QmlJs
import '../components' as PlatformComponents
import '../generic' as GenericComponents

WebViewPage {
    id: root
    property int headerHeight: 0
    property int editorControlsHeight: getEditorControlsHeight()
    property bool isMenuEnabled: true
    property bool hasOpenedFile: editorState.filePath !== ''
    property alias filePath: editorState.filePath
    allowedOrientations: Orientation.All

    onIsMenuEnabledChanged: {
        if (isMenuEnabled && hasOpenedFile) {
            hint.start()
        } else {
            hint.stop()
        }
    }

    onHasOpenedFileChanged: {
        if (!hasOpenedFile) {
            drawer.open = false
            hint.stop()
        }
    }

    background: Rectangle {
        color: editorState.isDarkTheme ? QmlJs.colors.DARK_BACKGROUND : QmlJs.colors.LIGHT_BACKGROUND
        height: root.height
        width: root.width
    }

    Component.onCompleted: {
        pageStack.busyChanged.connect(function() {
            if (!hasOpenedFile) {
                return
            }

            if (!pageStack.busy) {
                root.isMenuEnabled = false
            }
        })

        Qt.inputMethod.visibleChanged.connect(function() {
            api.oskVisibilityChanged(Qt.inputMethod.visible)
        })
    }

    PlatformComponents.Configuration {
        id: configuration
    }

    GenericComponents.EditorState {
        id: editorState
        isDarkTheme: Theme.colorScheme === Theme.LightOnDark
        directory: api.homeDir
        fontSize: configuration.fontSize
        useWrapMode: configuration.useWrapMode
        verticalHtmlOffset: (headerHeight + editorControlsHeight) / WebEngineSettings.pixelRatio
        filePath: tabsModel.currentTab ? tabsModel.currentTab.filePath : ''
        placeSearchOnTop: false

        onFilePathChanged: {
            if (filePath) {
                // display correspoding editor when file path changes
                api.openFile(filePath)
            } else {
                // pulley menus are always enable if no file opened
                isMenuEnabled = true
            }
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
            const tab = tabsModel.getTab(data.filePath)
            if (tab && tab.hasChanges !== data.hasChanges) {
                tabsModel.patch(data.filePath, { hasChanges: data.hasChanges })
            }

            editorState.hasChanges = data.hasChanges
            editorState.hasUndo = !data.isReadOnly && data.hasUndo
            editorState.hasRedo = !data.isReadOnly && data.hasRedo
            editorState.isReadOnly = data.isReadOnly
        }
    }

    PlatformComponents.Tabs {
        id: drawer
        title: qsTr('Opened files')

        anchors.fill: parent
        dock: root.isPortrait ? Dock.Top : Dock.Left
        model: tabsModel

        onSelected: function(tabId) {
            drawer.open = false
            const newIndex = tabsModel.getIndex(tabId)
            tabsModel.currentIndex = newIndex !== undefined ? newIndex : -1
        }
        onClosedAll: {
            const tabs = tabsModel.listFiles()
            const tabIds = tabs.map(function(tab) { return tab.id });
            closeTabs(tabIds);
        }
        onClosed: function(tabId) {
            closeTabs([tabId])
        }
        onOpenChanged: {
            if (open) {
                returnToEditorHint.start()
                returnToEditorHintLabel.opacity = 1.0
            } else {
                returnToEditorHint.stop()
                returnToEditorHintLabel.opacity = 0.0
            }
        }
        onNewTabRequested: {
            pageStack.push(filePicker)
        }

        WebViewFlickable {
            id: viewFlickable
            anchors.fill: parent
            header: PageHeader {
                page: root
                title: hasOpenedFile
                    ? ((editorState.hasChanges ? '*' : '') + QmlJs.getFileName(filePath))
                    : qsTr('Seabass v%1').arg('1.1.0')
                description: hasOpenedFile
                    ? QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir)
                    : qsTr('Release notes')

                onHeightChanged: {
                    headerHeight = height
                }

                Component.onCompleted: {
                    headerHeight = height

                    const TabsButton = Qt.createComponent("../components/TabsButton.qml");
                    const btn = TabsButton.createObject(extraContent, {
                        visible: hasOpenedFile,
                        'anchors.verticalCenter': extraContent.verticalCenter,
                    })
                    tabsModel.countChanged.connect(function() {
                        btn.text = tabsModel.count
                    })
                    root.hasOpenedFileChanged.connect(function() {
                        btn.visible = hasOpenedFile
                    })
                    btn.clicked.connect(function() {
                        Qt.inputMethod.hide()
                        drawer.open = true
                    })
                    leftMargin = btn.width + Theme.paddingMedium * 2
                    extraContent.anchors.leftMargin = Theme.paddingMedium
                }

                // Show divider between  header and editor when file is opened
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
                        pageStack.push(filePicker)
                    }
                }
                MenuItem {
                    enabled: !api.isSaveInProgress && !editorState.isReadOnly
                    visible: hasOpenedFile
                    text: api.isSaveInProgress ? qsTr("Saving...") : qsTr("Save")
                    onClicked: {
                        api.requestFileSave(editorState.filePath)
                    }
                }
                MenuItem {
                    text: qsTr("Close")
                    enabled: !api.isSaveInProgress && tabsModel.currentIndex !== -1
                    visible: hasOpenedFile
                    onClicked: {
                        closeTabs([tabsModel.currentTab.id])
                    }
                }
            }

            PushUpMenu {
                visible: isMenuEnabled
                MenuItem {
                    text: qsTr('Find/Replace')
                    enabled: hasOpenedFile
                    onClicked: {
                        api.postMessage('toggleSearchPanel')
                    }
                }
                MenuItem {
                    text: toolbar.open ? qsTr("Hide toolbar") : qsTr("Show toolbar")
                    onClicked: {
                        configuration.isToolbarVisible = !toolbar.open
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
                open: configuration.isToolbarVisible
                background: Rectangle {
                    // default background doesn't look good when virtual keyboard is opened
                    // hence the workaround with Rectangle
                    color: editorState.isDarkTheme
                           ? QmlJs.colors.DARK_TOOLBAR_BACKGROUND
                           : QmlJs.colors.LIGHT_TOOLBAR_BACKGROUND
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
                visible: isMenuEnabled
                onClicked: {
                    if (hasOpenedFile) {
                        isMenuEnabled = false
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                visible: drawer.open
                onClicked: {
                    drawer.open = false
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
                running: false
            }
            TapInteractionHint {
                id: returnToEditorHint
                running: false
                anchors.centerIn: parent
            }
            InteractionHintLabel {
                id: returnToEditorHintLabel
                anchors.bottom: parent.bottom
                opacity: 0.0
                Behavior on opacity { FadeAnimation {} }
                text: qsTr('Return to editor')
            }
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
                tabsModel.open({
                    id: filePath,
                    filePath: filePath,
                    subTitle: QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir),
                    title: QmlJs.getFileName(filePath)
                })
            }
        }
    }

    Component {
        id: settings
        Settings {
            fontSize: configuration.fontSize
            useWrapMode: configuration.useWrapMode

            onFontSizeChanged: {
                configuration.fontSize = fontSize
            }
            onUseWrapModeChanged: {
                configuration.useWrapMode = useWrapMode
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

    function getEditorControlsHeight() {
        const isPortrait = root.orientation & Orientation.PortraitMask
        const keyboardHeight = isPortrait
            ? Qt.inputMethod.keyboardRectangle.height
            : Qt.inputMethod.keyboardRectangle.width
        const toolbarHeight = toolbar.open ? toolbar.height : 0
        return keyboardHeight + toolbarHeight
    }

    function getEditorHeight() {
        return root.orientation & Orientation.PortraitMask
            ? Screen.height
            : Screen.width
    }

    function closeTabs(tabIds) {
        if (tabIds.length === 0) {
            return
        }

        const tabId = tabIds.shift()
        const tab = tabsModel.getTab(tabId)
        if (!tab.hasChanges) {
            tabsModel.close(tabId)
            closeTabs(tabIds)
            return
        }

        pageStack.push(Qt.resolvedUrl('SaveDialog.qml'), {
            filePath: tab.filePath,
            acceptDestination: root,
            acceptDestinationAction: PageStackAction.Pop
        })
        pageStack.currentPage.accepted.connect(function() {
            tabsModel.close(tab.id)

            if (tabIds.length) {
                const callback = function() {
                    if (pageStack.busy) {
                        return
                    }
                    pageStack.busyChanged.disconnect(callback)
                    closeTabs(tabIds)
                }
                pageStack.busyChanged.connect(callback)
            }
        })
    }
}
