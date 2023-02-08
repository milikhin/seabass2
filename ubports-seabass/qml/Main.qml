import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import Qt.labs.platform 1.0
import Qt.labs.settings 1.0
import QtWebSockets 1.0
import io.thp.pyotherside 1.4

import Lomiri.Components.Themes 1.3

import "./components" as CustomComponents
import "./generic" as GenericComponents
import "./generic/utils.js" as QmlJs
import "./constants.js" as Constants

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
  readonly property string version: "2.0.1"

  property bool hasBuildContainer: false
  property bool isLibertineEnabled: false
  property int activeTheme: parseInt(settings.theme)
  property var currentTab: tabBar.currentIndex === -1
    ? undefined
    : tabsModel.get(tabBar.currentIndex)

  onClosing: {
    settings.initialFiles = tabsModel.listFiles().map(tab => tab.filePath)
    settings.initialTab = currentTab && !currentTab.isTerminal
      ? settings.initialFiles.indexOf(currentTab.filePath)
      : 0
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

  readonly property var py: Python {
    Component.onCompleted: {
      addImportPath(Qt.resolvedUrl('../py-backend'))
      importModule('fs_utils', function() {
        py.call('fs_utils.test_exec', ['libertine-container-manager'], function(hasLibertine) {
          root.isLibertineEnabled = hasLibertine
        })
      })
    }
  }

  Settings {
    id: settings
    property bool isKeyboardExtensionVisible: true
    property string theme: Constants.Theme.System
    property int fontSize: 12
    property string initialDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    property var initialFiles: []
    property int initialTab: 0
    property bool restoreOpenedTabs: true
    property bool useWrapMode: true

    onFontSizeChanged: {
      editorState.fontSize = fontSize
    }
    onUseWrapModeChanged: {
      editorState.useWrapMode = useWrapMode
    }
  }

  GenericComponents.EditorState {
    id: editorState

    filePath: currentTab ? currentTab.filePath : ''

    isDarkTheme: QmlJs.isDarker(theme.palette.normal.background,
      theme.palette.normal.backgroundText)
    backgroundColor: theme.palette.normal.background
    textColor: theme.palette.normal.backgroundSecondaryText
    linkColor: theme.palette.normal.backgroundText

    fontSize: settings.fontSize
    useWrapMode: settings.useWrapMode
  }

  CustomComponents.UbuntuApi {
    id: api
    onServerStarted: function(port) {
      editor.load(port)
    }
    onAppLoaded: {
      editorState.loadTheme()
      editorState.updateViewport()
    }
    onFileBeingClosed: function (filePath) {
      tabsModel.close(filePath)
    }
  }

  GenericComponents.TabsModel {
    id: tabsModel
    onTabAdded: function(tab, options) {
      if (tab.isTerminal) {
        api.postMessage('loadFile', {
          filePath: tab.id,
          content: '',
          isTerminal: true,
          isActive: !options.doNotActivate
        })
      } else {
        api.loadFile({
          filePath: tab.filePath,
          createIfNotExists: options.createIfNotExists,
          callback: function(err, isNewFile) {
            if (err) {
              tabsModel.close(tab.filePath)
            }
          },
          isActive: !options.doNotActivate
        })
      }
    }
    onTabClosed: function(tabId) {
      api.closeFile(tabId)
    }
  }

  CustomComponents.Builder {
    id: builder
    disabled: !isLibertineEnabled

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
          isLibertineEnabled: root.isLibertineEnabled

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
          title: currentTab ? currentTab.uniqueTitle : defaultTitle
          subtitle: currentTab ? currentTab.subTitle : defaultSubTitle
          isLibertineEnabled: root.isLibertineEnabled
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
              hasBuildContainer: root.hasBuildContainer,
              isLibertineEnabled: root.isLibertineEnabled
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
            api.requestFileSave(editorState.filePath)
          }
          onBuildRequested: {
            const configFile = editorState.filePath
            builder.build(configFile, function(err, result) {
              if (err) {
                return errorDialog.show(
                  i18n.tr('Build (%1) failed. See build output for details').arg(configFile)
                )
              }
            }, handleBuilderStarted)
          }
          onLaunchRequested: {
            const configFile = editorState.filePath
            builder.launch(configFile, function(err, result) {
              if (err) {
                return errorDialog.show(
                  i18n.tr('Build and run (%1) failed. See build output for details').arg(configFile)
                )
              }
            }, handleBuilderStarted)
          }
          navBarCanBeOpened: !isWide || !navBar.visible
          canBeSaved: editorState.filePath && editorState.hasChanges
          buildEnabled: editorState.filePath && builder.ready
          buildable: editorState.filePath && editorState.filePath.match(/\/clickable\.(json|yaml)$/)
          keyboardExtensionEnabled: settings.isKeyboardExtensionVisible && main.visible && tabsModel.count
          searchEnabled: main.visible && tabsModel.count
          terminalEnabled: main.visible && tabsModel.count
          onKeyboardExtensionToggled: settings.isKeyboardExtensionVisible = !settings.isKeyboardExtensionVisible
          onSearch: {
            editor.forceActiveFocus()
            api.postMessage('toggleSearch')
          }
          onOpenTerminalApp: {
              if (editorState.filePath) {
                  Qt.openUrlExternally("terminal://?path=" + editorState.filePath.split('/').slice(0, -1).join('/'))
              }
          }
        }

        CustomComponents.TabBar {
          id: tabBar
          model: tabsModel
          visible: model.count
          Layout.fillWidth: true

          onOpened: function(tabId) {
            api.openFile(tabId)
          }
        }

        CustomComponents.EditorView {
          id: editor
          Layout.fillWidth: true
          Layout.fillHeight: true
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
  onActiveThemeChanged: {
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

    editorState.isDarkTheme = QmlJs.isDarker(theme.palette.normal.background,
      theme.palette.normal.backgroundText);
  }
}
