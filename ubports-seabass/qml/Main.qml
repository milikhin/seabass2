import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Morph.Web 0.1
import QtWebEngine 1.1
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import Ubuntu.Components.Popups 1.3
import Qt.labs.platform 1.0

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
  readonly property string defaultTitle: qsTr("Welcome")
  readonly property string defaultSubTitle: "Seabass"

  GenericComponents.FilesModel {
    id: filesModel
  }

  GenericComponents.EditorApi {
    id: api
    homeDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)
    onMessageSent: function(jsonPayload) {
      editor.runJavaScript("window.postSeabassApiMessage(" + jsonPayload + ")");
    }
    onHasChangesChanged: {
      if (!filePath) {
        return
      }
      const fileIndex = filesModel.getIndex(filePath)
      const file = filesModel.get(fileIndex)
      file.hasChanges = hasChanges
      filesModel.set(fileIndex, file)
    }
  }

  CustomComponents.SaveDialog {
    id: saveDialog
  }

  Page {
    id: page
    anchors.fill: parent

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
          homeDir: api.homeDir
          onClosed: navBar.visible = false
          isPage: !isWide
          Layout.fillWidth: true
          Layout.fillHeight: true

          onFileSelected: function(filePath) {
            const existingTabIndex = filesModel.open(filePath)
            if (existingTabIndex !== undefined) {
              tabBar.currentIndex = existingTabIndex
            } else {
              api.loadFile(filePath)
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

        PageHeader {
          id: header
          title: api.filePath ? QmlJs.getFileNameByPath(api.filePath) : defaultTitle
          subtitle: api.filePath ? QmlJs.getShortDirName(api.filePath, api.homeDir): defaultSubTitle
          Layout.fillWidth: true

          navigationActions: [
            Action {
              visible: !isWide || !navBar.visible
              iconName: "navigation-menu"
              text: qsTr("Files")
              onTriggered: navBar.visible = !navBar.visible
            }
          ]
          trailingActionBar {
            actions: [
              Action {
                iconName: "save"
                text: qsTr("Save")
                enabled: api.filePath && api.hasChanges
                onTriggered: api.requestSaveFile()
              }
            ]
          }
        }

        CustomComponents.TabBar {
          id: tabBar
          model: filesModel
          visible: model.count
          Layout.minimumHeight: model.count ? units.gu(4.5) : 0
          Layout.fillWidth: true

          onCurrentIndexChanged: {
            if (currentIndex === -1) {
              return
            }

            const file = model.get(currentIndex)
            api.openFile(file.filePath)
          }
          onTabClosed: function(index) {
            const file = model.get(index)
            if (!file.hasChanges) {
              return __close()
            }

            saveDialog.show(file.filePath, {
              onSaved: function() {
                api.requestSaveFile()
                // TODO: wait until the file actually saved
                __close()
              },
              onDismissed: __close
            })

            function __close() {
              api.closeFile(file.filePath)
              model.remove(index, 1)

              if (!model.count) {
                api.filePath = ''
                return
              }

              if (currentIndex === -1) {
                currentIndex = 0
              }
            }
          }
        }

        WebView {
          id: editor
          width: parent.width
          Layout.fillWidth: true
          Layout.fillHeight: true

          url: "./html/index.html"
          onNavigationRequested: function(request) {
            const urlStr = request.url.toString()
            const isHttpRequest = urlStr.indexOf('http') === 0
            if (!isHttpRequest) {
              return
            }

            request.action = WebEngineNavigationRequest.IgnoreRequest
            const apiPrefix = 'http://seabass/'
            if (urlStr.indexOf(apiPrefix) === 0) {
              const messageStr = decodeURIComponent(urlStr.slice(apiPrefix.length))
              const payload = JSON.parse(messageStr)
              return api.handleMessage(payload.action, payload.data)
            }

            Qt.openUrlExternally(request.url)
          }
          zoomFactor: units.gu(1) / 8
        }
      }
    }
  }
}
