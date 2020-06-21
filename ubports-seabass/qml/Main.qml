import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Morph.Web 0.1
import QtWebEngine 1.1
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import Ubuntu.Components.Popups 1.3
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0

import "./components" as CustomComponents
import "./generic" as GenericComponents
import "./generic/utils.js" as QmlJs

MainView {
  id: root
  objectName: 'mainView'
  applicationName: 'seabass2.mikhael'
  automaticOrientation: true
  anchorToKeyboard: true

  width: units.gu(100)
  height: units.gu(60)

  readonly property bool isWide: width >= units.gu(100)
  readonly property string defaultTitle: i18n.tr("Welcome")
  readonly property string defaultSubTitle: "Seabass"
  readonly property string version: "0.5.0"

  Settings {
    id: settings
    property bool isKeyboardExtensionVisible: true
  }

  PageStack {
    id: pageStack

    Component.onCompleted: {
      pageStack.push(page)
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
            tabsModel.close(filePath)
          }
          if (isNewFile) {
            fileList.reload()
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

    GenericComponents.EditorApi {
      id: api

      // UI theme
      isDarkTheme: QmlJs.isDarker(theme.palette.normal.background,
        theme.palette.normal.backgroundText)
      backgroundColor: theme.palette.normal.background
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

    CustomComponents.ErrorDialog {
      id: errorDialog
    }

    CustomComponents.NewFileDialog {
      id: newFileDialog
      homeDir: api.homeDir
    }

    CustomComponents.SaveDialog {
      id: saveDialog
    }

    CustomComponents.ConfirmDialog {
      id: confirmDialog
    }

    CustomComponents.Builder {
      id: builder
      onUnhandledError: function(message) {
        errorDialog.show('Unhandled python backend error:\n' + message)
      }
    }

    Page {
      id: page
      visible: false
      anchors.fill: parent
      background: Rectangle {
        color: theme.palette.normal.background
      }

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
          Layout.minimumWidth: isWide ? units.gu(30) : parent.width
          Layout.maximumWidth: isWide ? units.gu(40) : parent.width

          CustomComponents.FileList {
            id: fileList
            homeDir: api.homeDir
            onClosed: navBar.visible = false
            isPage: !isWide
            Layout.fillWidth: true
            Layout.fillHeight: true

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
            subtitle: defaultSubTitle
            Layout.fillWidth: true

            onNavBarToggled: navBar.visible = !navBar.visible
            onAboutPageRequested: pageStack.push(Qt.resolvedUrl("About.qml"), { version: root.version })
            onSaveRequested: {
              api.getFileContent(function(fileContent) {
                api.saveFile(api.filePath, fileContent)
              })
            }
            onBuildRequested: {
              builder.testContainer(function(error, containerExists) {
                if (error) {
                  errorDialog.show(i18n.tr(error))
                }
                if (containerExists) {
                  return __build()
                }

                confirmDialog.show({
                  text: i18n.tr("A Libertine container is going to be created in order to execute build commands. " +
                    "The process might take a while, but you can continue using the Seabass " +
                    "while the container is being created. " +
                    "Your network connection will be used to fetch required packages."),
                  onOk: __build,
                  onCancel: function() {}
                })
              })

              function __build() {
                const configFile = api.filePath
                const tabId = '__seabass2_build_output'
                const title = 'Build output'
                const subTitle = QmlJs.getPrintableFilePath(configFile, api.homeDir)
                tabsModel.openTerminal(tabId, title, subTitle)
                builder.build(configFile, function(line) {
                  api.postMessage('appendContent', {
                    filePath: tabId,
                    content: line
                  })
                }, function(err, result) {
                  tabsModel.patch(tabId, { isBusy: false })
                  if(err) {
                    errorDialog.show(
                      i18n.tr('Build (%1) failed. See build output for details').arg(configFile)
                    )
                  }
                })
              }
            }
            navBarCanBeOpened: !isWide || !navBar.visible
            canBeSaved: api.filePath && api.hasChanges
            buildEnabled: api.filePath && builder.ready
            buildable: api.filePath && api.filePath.match(/\/clickable\.json$/)
            keyboardExtensionAvailable: Qt.inputMethod.visible && main.visible && tabsModel.count
            onKeyboardExtensionToggled: settings.isKeyboardExtensionVisible = !settings.isKeyboardExtensionVisible
          }

          CustomComponents.TabBar {
            id: tabBar
            model: tabsModel
            visible: model.count
            Layout.minimumHeight: model.count ? units.gu(4.5) : 0
            Layout.fillWidth: true

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
            onTabClosed: function(index) {
              const file = model.get(index)
              if (!file.hasChanges) {
                return __close()
              }

              saveDialog.show(file.idd, {
                onSaved: api.getFileContent(_saveAndClose),
                onDismissed: __close()
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
            width: parent.width
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
  }
}
