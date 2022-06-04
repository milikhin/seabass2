import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0

import Ubuntu.Components.Themes 1.3

import "./components" as CustomComponents
import "./generic" as GenericComponents
import "./generic/utils.js" as QmlJs
import "./constants.js" as Constants

ApplicationWindow {
  id: root
  title: 'Seabass2'
  width: Suru.units.gu(100)
  height: Suru.units.gu(60)

  property string filePath

  overlay.modal: Rectangle {
    color: "transparent"
  }

  readonly property bool isWide: width >= Suru.units.gu(100)
  readonly property string defaultTitle: i18n.tr("Welcome")
  readonly property string defaultSubTitle: i18n.tr("Seabass2")
  readonly property string version: "1.4.0"
  property bool hasBuildContainer: false
  property int activeTheme: parseInt(settings.theme)

  onClosing: {
    var files = []
    for (var i = 0; i < tabsModel.count; i++) {
      var tab = tabsModel.get(i)
      if (tab.isTerminal) {
        continue
      }

      files.push(tab.filePath)
      if (i === tabBar.currentIndex) {
        settings.initialTab = files.length - 1
      }
    }

    settings.initialFiles = files
  }

  function handleBuilderStarted() {
    if (!isWide) {
      navBar.visible = false
    }
    pageStack.pop(mainView)
  }

  Component.onCompleted: {
    i18n.domain = "seabass2.mikhael"
  }

  Settings {
    id: settings
    property bool isKeyboardExtensionVisible: true
    property string theme: Constants.Theme.System
    property int fontSize: 12
    property var initialFiles: []
    property string initialDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property int initialTab: 0
    property bool restoreOpenedTabs: true
    property bool useWrapMode: true
  }

  GenericComponents.EditorApi {
    id: api

    // UI theme
    fontSize: settings.fontSize
    useWrapMode: settings.useWrapMode
    isDarkTheme: QmlJs.isDarker(theme.palette.normal.background,
      theme.palette.normal.backgroundText)
    backgroundColor: theme.palette.normal.background
    borderColor: QmlJs.isDarker(theme.palette.normal.background,
      theme.palette.normal.backgroundText) ? Suru.darkMid: Suru.lightMid
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
    onAppLoaded: {
      if (settings.restoreOpenedTabs) {
        for (var i = 0; i < settings.initialFiles.length; i++) {
          var filePath = settings.initialFiles[i]
          tabsModel.open({
            id: filePath,
            filePath: filePath,
            subTitle: QmlJs.getPrintableDirPath(QmlJs.getDirPath(filePath), api.homeDir),
            title: QmlJs.getFileName(filePath),
            isInitial: true,
            doNotActivate: settings.initialTab !== i
          })
        }
      }
    }
    onMessageSent: function(jsonPayload) {
      editor.runJavaScript("window.postSeabassApiMessage(" + jsonPayload + ")");
    }
    onHasChangesChanged: {
      const file = tabsModel.get(tabBar.currentIndex)
      file.hasChanges = hasChanges
      tabsModel.set(tabBar.currentIndex, file)
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
      api.loadFile(tab.filePath, false, !tab.isInitial, tab.doNotActivate, function(err, isNewFile) {
        if (err) {
          tabsModel.close(tab.filePath)
        }
      })
    }
    onTabClosed: function(tabId) {
      api.closeFile(tabId)

      // display current tab
      if (!count) {
        return
      }
      var currentFile = get(tabBar.currentIndex)
      api.openFile(currentFile.filePath)
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

    onReadyChanged: {
      builder._testContainer(function(err, containerExists) {
        if (err) {
          return
        }
        root.hasBuildContainer = containerExists
      })
    }
  }

  StackView {
    id: pageStack
    initialItem: mainView
    anchors.fill: parent
    anchors.bottomMargin: Qt.inputMethod.visible
      ? Qt.inputMethod.keyboardRectangle.height / Screen.devicePixelRatio
      : 0
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
          isReady: api.isLoaded
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
          onProjectCreationInitialized: function(dirName) {
            pageStack.push(Qt.resolvedUrl("NewProject.qml"), {
              buildContainerReady: builder.ready,
              hasBuildContainer: root.hasBuildContainer,
              dirName: dirName,
              homeDir: api.homeDir
            })

            pageStack.currentItem.projectCreationRequested.connect(function(dirName, options) {
              builder.create(dirName, options, function(err, result) {
                if (err) {
                  return errorDialog.show(
                    i18n.tr('Creating a project failed. See build output for details')
                  )
                }
              }, handleBuilderStarted)
            })
          }
        }

        CustomComponents.Divider {
          isVertical: true
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
          onSettingsPageRequested: {
            pageStack.push(Qt.resolvedUrl("Settings.qml"), {
              version: root.version,
              buildContainerReady: builder.ready,
              hasBuildContainer: root.hasBuildContainer
            })

            pageStack.currentItem.containerCreationStarted.connect(function() {
              builder.ensureContainer(function(err, result) {
                if (err) {
                  return errorDialog.show(
                    i18n.tr('Creating a Libertine container failed. See build output for details')
                  )
                }
              }, handleBuilderStarted)
            })

            pageStack.currentItem.containerUpdateStarted.connect(function() {
              builder.update(function(err, result) {
                if (err) {
                  return errorDialog.show(
                    i18n.tr('Update failed. See build output for details')
                  )
                }
              }, handleBuilderStarted)
            })
          }
          onSaveRequested: {
            api.getFileContent(function(fileContent) {
              api.saveFile(root.filePath, fileContent)
            })
          }
          onBuildRequested: {
            const configFile = root.filePath
            builder.build(configFile, function(err, result) {
              if (err) {
                return errorDialog.show(
                  i18n.tr('Build (%1) failed. See build output for details').arg(configFile)
                )
              }
            }, handleBuilderStarted)
          }
          onLaunchRequested: {
            const configFile = root.filePath
            builder.launch(configFile, function(err, result) {
              if (err) {
                return errorDialog.show(
                  i18n.tr('Build and run (%1) failed. See build output for details').arg(configFile)
                )
              }
            }, handleBuilderStarted)
          }
          navBarCanBeOpened: !isWide || !navBar.visible
          // TODO: fix saving files before enabling `canBeSaved`
          canBeSaved: false // root.filePath && api.hasChanges
          buildEnabled: root.filePath && builder.ready
          buildable: root.filePath && root.filePath.match(/\/clickable\.json$/)
          keyboardExtensionEnabled: settings.isKeyboardExtensionVisible && main.visible && tabsModel.count
          searchEnabled: main.visible && tabsModel.count
          terminalEnabled: main.visible && tabsModel.count
          onKeyboardExtensionToggled: settings.isKeyboardExtensionVisible = !settings.isKeyboardExtensionVisible
          onSearch: {
            editor.forceActiveFocus()
            api.postMessage('toggleSearch')
          }
          onOpenTerminalApp: {
              if (root.filePath) {
                  Qt.openUrlExternally("terminal://?path=" + root.filePath.split('/').slice(0, -1).join('/'))
              }
          }
        }

        CustomComponents.TabBar {
          id: tabBar
          model: tabsModel
          visible: model.count
          Layout.fillWidth: true

          onCurrentIndexChanged: {
            if (!model.count) {
              header.title = defaultTitle
              header.subtitle = defaultSubTitle
              root.filePath = undefined
              return
            }

            if (currentIndex === -1) {
              currentIndex = 0
              return
            }

            const tab = model.get(currentIndex)
            root.filePath = tab.filePath
            header.title = tab.title
            header.subtitle = tab.subTitle
            api.openFile(tab.id)
          }
          onClose: function(index) {
            _close([model.get(index)])
          }
          onCloseAll: function() {
            const files = []
            for (var i = 0; i < model.count; i++) {
              const file = model.get(i)
              files.push({ hasChanges: file.hasChanges, id: file.id })
            }
            _close(files)
          }
          onCloseToTheRight: function(startIndex) {
            if (startIndex === model.count - 1) {
              return
            }

            const files = []
            for (var i = startIndex + 1; i < model.count; i++) {
              const file = model.get(i)
              files.push({ hasChanges: file.hasChanges, id: file.id })
            }
            _close(files)
          }

          function _close(files) {
            const file = files.shift()
            if (!file.hasChanges) {
              return __closeAndContinue()
            }

            saveDialog.show(file.id, {
              onSaved: function() {
                api.getFileContent(__saveAndClose)
              },
              onDismissed: __closeAndContinue
            })

            function __closeAndContinue() {
              model.close(file.id)
              if (!files.length) {
                return
              }
              _close(files)
            }

            function __saveAndClose(fileContent) {
              api.saveFile(file.id, fileContent, function(err) {
                if (err) {
                  return
                }
                __closeAndContinue()
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

        CustomComponents.Divider {
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

  /*
    Sets the system theme according to the theme selected
    under settings.
  */
  function setCurrentTheme() {
    switch (activeTheme) {
      case Constants.Theme.System:
        theme.name = "";
        Suru.theme = undefined;
        break;
      case Constants.Theme.SuruLight:
        theme.name = "Ubuntu.Components.Themes.Ambiance";
        Suru.theme = Suru.Light;
        break;
      case Constants.Theme.SuruDark:
        theme.name = "Ubuntu.Components.Themes.SuruDark";
        Suru.theme = Suru.Dark;
        break;
    }

    api.isDarkTheme = QmlJs.isDarker(theme.palette.normal.background,
      theme.palette.normal.backgroundText);
  }

  onActiveThemeChanged: setCurrentTheme()
}
