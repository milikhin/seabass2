import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0

import Ubuntu.Components.Themes 1.3

import "./components" as CustomComponents
import "./generic" as GenericComponents
import "./generic/utils.js" as QmlJs

ApplicationWindow {
  id: root
  title: 'Seabass2'
  width: Suru.units.gu(100)
  height: Suru.units.gu(60)

  overlay.modal: Rectangle {
    color: "transparent"
  }

  readonly property bool isWide: width >= Suru.units.gu(100)
  readonly property string defaultTitle: i18n.tr("Welcome")
  readonly property string defaultSubTitle: i18n.tr("Seabass2")
  readonly property string version: "0.8.0"

  Component.onCompleted: {
    i18n.domain = "seabass2.mikhael"
  }

  Settings {
    id: settings
    property bool isKeyboardExtensionVisible: true
  }

  GenericComponents.EditorApi {
    id: api

    // UI theme
    isDarkTheme: QmlJs.isDarker(theme.palette.normal.background,
      theme.palette.normal.backgroundText)
    backgroundColor: theme.palette.normal.background
    borderColor: theme.palette.normal.overlaySecondaryText
    textColor: theme.palette.normal.backgroundSecondaryText
    linkColor: theme.palette.normal.backgroundText
    foregroundColor: theme.palette.normal.foreground
    foregroundTextColor: theme.palette.normal.foregroundText
    homeDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)

    // platform-specific i18n implementation for Generic API
    readErrorMsg: i18n.tr('Unable to read file. Please ensure that you have read access to the %1')
    writeErrorMsg: i18n.tr('Unable to write the file. Please ensure that you have write access to %1')

    // API methods
    onErrorOccured: function(message) {
      errorDialog.show(message)
    }
    onMessageSent: function(jsonPayload) {
      editor.runJavaScript("window.postSeabassApiMessage(" + jsonPayload + ")");
    }
    onHasChangesChanged: {
      if (!filePath) {
        return
      }
      const fileIndex = tabsModel.getIndex(filePath)
      const file = tabsModel.get(fileIndex)
      file.hasChanges = hasChanges
      tabsModel.set(fileIndex, file)
    }

    /**
    * Returns current content of the given file from the EditorApi
    *  (the API backend must support returning a result from a JS call for this method to work)
    * @param {function} - callback
    * @returns {string} - file content
    */
    function getFileContent(callback) {
      const jsonPayload = JSON.stringify({
        action: 'getFileContent',
        data: {
          filePath: filePath
        }
      })
      return editor.runJavaScript("window.postSeabassApiMessage(" + jsonPayload + ")", callback);
    }
  }

  GenericComponents.TabsModel {
    id: tabsModel
    onTabAdded: function(tab) {
      if (tab.isTerminal) {
        return api.postMessage('loadFile', {
          filePath: tab.id,
          content: '',
          readOnly: true,
          isTerminal: true
        })
      }
      api.loadFile(tab.filePath, false, function(err, isNewFile) {
        if (err) {
          tabsModel.close(tab.filePath)
        }
      })
    }
    onTabClosed: function(tabId) {
      api.closeFile(tabId)
    }
    onCountChanged: {
      if (!count) {
        api.filePath = ''
      }
    }
  }

  CustomComponents.Builder {
    id: builder

    onStarted: {
      const existingTabIndex = tabsModel.openTerminal(builder.tabId, builder.title, builder.subTitle)
      if (existingTabIndex !== undefined) {
        tabBar.currentIndex = existingTabIndex
        api.postMessage('setContent', { filePath: builder.tabId, content: '' })
      }
      tabsModel.patch(builder.tabId, { isBusy: true })
    }
    onCompleted: {
      tabsModel.patch(builder.tabId, { isBusy: false })
    }
    onStdout: function(line) {
      api.postMessage('setContent', {
        filePath: builder.tabId,
        content: line,
        append: true
      })
    }
    onUnhandledError: function(message) {
      errorDialog.show('Unhandled python backend error:\n' + message)
    }
  }

  StackView {
    id: pageStack
    initialItem: mainView
    anchors.fill: parent
    anchors.bottomMargin: Qt.inputMethod.visible ? Qt.inputMethod.keyboardRectangle.height : 0
  }

  CustomComponents.ErrorDialog {
    id: errorDialog
  }

  CustomComponents.SaveDialog {
    id: saveDialog
  }

  Item {
    id: mainView

    RowLayout {
      anchors.fill: parent
      spacing: 0

      RowLayout {
        id: navBar
        z: 1
        visible: isWide
        spacing: 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: isWide ? Suru.units.gu(35) : parent.width
        Layout.maximumWidth: Layout.minimumWidth
        Layout.preferredWidth: Layout.minimumWidth

        CustomComponents.FileList {
          id: fileList
          homeDir: api.homeDir
          onClosed: navBar.visible = false
          isPage: !isWide
          Layout.fillWidth: true
          Layout.fillHeight: true

          onErrorOccured: function(message) {
            errorDialog.show(message)
          }
          onFileSelected: function(filePath) {
            const existingTabIndex = tabsModel.open({
              id: filePath,
              filePath: filePath,
              subTitle: QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir),
              title: QmlJs.getFileName(filePath)
            })
            if (existingTabIndex !== undefined) {
              tabBar.currentIndex = existingTabIndex
            }

            if (!isWide) {
              navBar.visible = false
            }
          }
        }
        Rectangle {
          Layout.minimumWidth: 1
          Layout.fillHeight: true
          color: theme.palette.normal.overlaySecondaryText
          visible: isWide
        }
      }

      ColumnLayout {
        id: main
        visible: isWide || !navBar.visible
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        CustomComponents.Header {
          id: header
          title: defaultTitle
          subtitle: root.title
          Layout.fillWidth: true

          onNavBarToggled: {
            navBar.visible = !navBar.visible
            if (!isWide) {
              Qt.inputMethod.hide()
            }
          }
          onAboutPageRequested: pageStack.push(Qt.resolvedUrl("About.qml"), { version: root.version })
          onSaveRequested: {
            api.getFileContent(function(fileContent) {
              api.saveFile(api.filePath, fileContent)
            })
          }
          onBuildRequested: {
            const configFile = api.filePath
            builder.build(configFile, function(err, result) {
              if (err) {
                return errorDialog.show(
                  i18n.tr('Build (%1) failed. See build output for details').arg(configFile)
                )
              }
            })
          }
          navBarCanBeOpened: !isWide || !navBar.visible
          canBeSaved: api.filePath && api.hasChanges
          buildEnabled: api.filePath && builder.ready
          buildable: api.filePath && api.filePath.match(/\/clickable\.json$/)
          keyboardExtensionEnabled: settings.isKeyboardExtensionVisible && main.visible && tabsModel.count
          searchEnabled: main.visible && tabsModel.count
          onKeyboardExtensionToggled: settings.isKeyboardExtensionVisible = !settings.isKeyboardExtensionVisible
          onSearch: {
            api.postMessage('toggleSearch')
            editor.focus = true
          }
        }
        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Suru.neutralColor
        }

        CustomComponents.TabBar {
          id: tabBar
          model: tabsModel
          visible: model.count
          Layout.fillWidth: true
          Layout.preferredHeight: Suru.units.gu(4.5)

          onCurrentIndexChanged: {
            if (!model.count) {
              header.title = defaultTitle
              header.subtitle = defaultSubTitle
              return
            }

            if (currentIndex === -1) {
              currentIndex = 0
              return
            }

            const tab = model.get(currentIndex)
            header.title = tab.title
            header.subtitle = tab.subTitle
            api.openFile(tab.id)
          }
          onTabCloseRequested: function(index) {
            const file = model.get(index)
            if (!file.hasChanges) {
              return __close()
            }

            saveDialog.show(file.id, {
              onSaved: function() { api.getFileContent(__saveAndClose) },
              onDismissed: __close
            })

            function __close() {
              model.close(file.id)
            }

            function __saveAndClose(fileContent) {
              api.saveFile(file.id, fileContent, function(err) {
                if (err) {
                  return
                }
                __close()
              })
            }
          }
        }

        CustomComponents.EditorView {
          id: editor
          Layout.fillWidth: true
          Layout.fillHeight: true

          onMessageReceived: function(payload) {
            return api.handleMessage(payload.action, payload.data)
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: theme.palette.normal.overlaySecondaryText
          visible: keyboardExtension.visible
        }

        CustomComponents.KeyboardExtension {
          id: keyboardExtension
          Layout.fillWidth: true
          visible: settings.isKeyboardExtensionVisible && Qt.inputMethod.visible && main.visible && tabsModel.count
          onTabBtnClicked: api.postMessage('keyDown', { keyCode: 9 /* TAB */ })
          onEscBtnClicked: api.postMessage('keyDown', { keyCode: 27 /* ESC */ })
          onLeftArrowClicked: api.postMessage('keyDown', { keyCode: 37 /* LEFT */ })
          onRightArrowClicked: api.postMessage('keyDown', { keyCode: 39 /* RIGHT */ })
          onUpArrowClicked: api.postMessage('keyDown', { keyCode: 38 /* UP */ })
          onDownArrowClicked: api.postMessage('keyDown', { keyCode: 40 /* DOWN */ })
        }
      }
    }
  }
  // }
}
