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
    property string filePath
    property int headerHeight: 0
    property bool isMenuEnabled: true
    allowedOrientations: Orientation.All

    onFilePathChanged: {
        isMenuEnabled = false
    }

    onIsMenuEnabledChanged: {
        if (isMenuEnabled) {
            hint.start()
        } else {
            hint.stop()
        }
    }

    background: Rectangle {
        color: api.backgroundColor
        height: page.height
        width: page.width
    }

    GenericComponents.EditorApi {
        id: api
        homeDir: StandardPaths.home

        // UI theme
        isDarkTheme: Theme.colorScheme === Theme.LightOnDark
        backgroundColor: isDarkTheme ? QmlJs.colors.DARK_BACKGROUND : QmlJs.colors.LIGHT_BACKGROUND
        textColor: isDarkTheme ? QmlJs.colors.DARK_TEXT : QmlJs.colors.LIGHT_TEXT
        linkColor: textColor
        verticalHtmlOffset: headerHeight / WebEngineSettings.pixelRatio

        // platform-specific i18n implementation for Generic API
        readErrorMsg: qsTr('Unable to read file. Please ensure that you have read access to the %1')
        writeErrorMsg: qsTr('Unable to write the file. Please ensure that you have write access to %1')

        // API methods
        onAppLoaded: function (data) {
            toolbar.open = data.isToolbarOpened || false
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
    }

    WebViewFlickable {
        id: viewFlickable
        anchors.fill: parent
        header: PageHeader {
            page: page
            title: filePath
                ? ((api.hasChanges ? '*' : '') + QmlJs.getFileName(filePath))
                : qsTr('Seabass v%1').arg('0.9.0')
            description: filePath
                ? QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir)
                : 'Release notes'

            Component.onCompleted: {
                headerHeight = height
                // TODO: Part of multiple tabs support experiments
                // const TabsButton = Qt.createComponent("../components/TabsButton.qml");
                // const btn = TabsButton.createObject(extraContent, {
                //     text: '1',
                //     visible: filePath !== '',
                //     'anchors.verticalCenter': extraContent.verticalCenter,
                // })
                // page.filePathChanged.connect(function() {
                //     btn.visible = filePath !== ''
                // })
                // leftMargin = btn.width + Theme.paddingMedium * 2
                // extraContent.anchors.leftMargin = Theme.paddingMedium
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                color: api.isDarkTheme ? QmlJs.colors.DARK_DIVIDER : QmlJs.colors.LIGHT_DIVIDER
                height: filePath ? Theme.dp(1) : 0
            }
        }

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
            visible: isMenuEnabled
            MenuItem {
                text: qsTr("Open file...")
                onClicked: {
                    api.hasChanges
                        ? pageStack.push(Qt.resolvedUrl('SaveDialog.qml'), {
                                filePath: filePath,
                                acceptDestination: filePickerPage,
                                acceptDestinationAction: PageStackAction.Replace
                            })
                        : pageStack.push(filePickerPage)
                }
            }
            MenuItem {
                enabled: !api.isSaveInProgress
                visible: filePath && !api.isReadOnly
                text: api.isSaveInProgress ? qsTr("Saving...") : qsTr("Save")
                onClicked: {
                    api.requestFileSave(filePath)
                }
            }
        }

        PushUpMenu {
            visible: isMenuEnabled
            MenuItem {
                text: qsTr(toolbar.open ? "Hide toolbar" : "Show toolbar")
                onClicked: {
                    toolbar.open = !toolbar.open
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
                color: api.isDarkTheme
                       ? QmlJs.colors.DARK_TOOLBAR_BACKGROUND
                       : QmlJs.colors.LIGHT_TOOLBAR_BACKGROUND
            }

            onOpenChanged: {
                api.postMessage('setSailfishPreferences', {
                    isToolbarOpened: open
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
                onNavigateFileStart: api.postMessage('keyDown', { keyCode: 36 /* HOME */, ctrlKey: true })
                onNavigateFileEnd: api.postMessage('keyDown', { keyCode: 35 /* END */, ctrlKey: true })
            }
        }

        MouseArea {
            anchors.fill: parent
            visible: isMenuEnabled
            onClicked: {
                if (filePath !== '') {
                    isMenuEnabled = false
                }
            }
        }


        Rectangle {
            visible: filePath !== ''
            anchors.bottom: toolbar.open ? toolbar.top : parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            width: childrenRect.width
            height: childrenRect.height
            color: api.isDarkTheme
                ? QmlJs.colors.DARK_TOOLBAR_BACKGROUND
                : QmlJs.colors.LIGHT_TOOLBAR_BACKGROUND
            radius: Theme.dp(2)

            Button {
                icon.source: "image://theme/icon-m-gesture"
                onClicked: isMenuEnabled = !isMenuEnabled
                icon.color: isMenuEnabled ? Theme.highlightColor : Theme.primaryColor
                backgroundColor: Theme.rgba(Theme.highlightBackgroundColor,
                    isMenuEnabled ? Theme.highlightBackgroundOpacity : 0)
                border.color: Theme.highlightBackgroundColor
            }
        }

        TouchInteractionHint {
            id: hint
            direction: TouchInteraction.Down
        }
    }

    Component {
        id: filePickerPage
        FilePickerPage {
            onSelectedContentPropertiesChanged: {
                if (!selectedContentProperties.filePath) {
                    return
                }

                if (page.filePath) {
                    api.closeFile(page.filePath)
                }
                api.loadFile(selectedContentProperties.filePath, false, true, false, Function.prototype)
                api.openFile(selectedContentProperties.filePath)
                page.filePath = selectedContentProperties.filePath
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
        return windowHeight - dockHeight
    }
}
