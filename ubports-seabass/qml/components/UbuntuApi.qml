import QtQuick 2.9
import QtWebSockets 1.0
import Qt.labs.platform 1.0

import "../generic" as GenericComponents
import "../generic/utils.js" as QmlJs

GenericComponents.EditorApi {
  id: api

  property var server: WebSocketServer {
    listen: true
    onClientConnected: {
      if (webSocket.status === WebSocket.Open) {
        api.messageSent.connect(function(jsonPayload) {
          webSocket.sendTextMessage(jsonPayload)
        })
        webSocket.onTextMessageReceived.connect(function (message) {
          const payload = JSON.parse(message)
          api.handleMessage(payload.action, payload.data)
        })
      }
    }
    onErrorStringChanged: {
      console.log(qsTr("Server error: %1").arg(errorString));
    }

    Component.onCompleted: {
      serverStarted(port)
    }
  }

  signal serverStarted(int port)

  homeDir: StandardPaths.writableLocation(StandardPaths.HomeLocation)
  // platform-specific i18n implementation for Generic API
  readErrorMsg: i18n.tr('Unable to read file. Please ensure that you have read access to the %1')
  writeErrorMsg: i18n.tr('Unable to write the file. Please ensure that you have write access to %1')

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

  onErrorOccured: function(message) {
    errorDialog.show(message)
  }

  onStateChanged: function(data) {
    tabsModel.patch(data.filePath, { hasChanges: data.hasChanges })

    editorState.hasChanges = !data.isReadOnly && data.hasChanges
    editorState.hasUndo = !data.isReadOnly && data.hasUndo
    editorState.hasRedo = !data.isReadOnly && data.hasRedo
    editorState.isReadOnly = data.isReadOnly
  }
}
