import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import "../../generic/utils.js" as QmlJs

Item {
  property string dirPath
  property string originalFileName
  property string homeDir: ''
  property var onSubmit: function() {}

  function show(path, handler) {
    originalFileName = QmlJs.getFileName(path)
    dirPath = QmlJs.getDirPath(path)
    onSubmit = function(newFileName) {
      const newFileUrl = Qt.resolvedUrl(dirPath + '/' + newFileName)
      const newFilePath = QmlJs.getNormalPath(newFileUrl)
      handler(newFilePath)
    }
    dialogue.visible = true
  }

  Dialog {
    id: dialogue
    parent: ApplicationWindow.overlay
    modal: true
    title: i18n.tr("Rename %1").arg(originalFileName)
    standardButtons: Dialog.Ok | Dialog.Cancel
    x: (parent.width - width) / 2
    y: (parent.height - height - Qt.inputMethod.keyboardRectangle.height / Screen.devicePixelRatio) / 2
    onAccepted: {
      onSubmit(fileName.text)
    }
    onVisibleChanged: {
      if (visible) {
        fileName.text = originalFileName
        fileName.forceActiveFocus()
      }
    }

    ColumnLayout {
      spacing: 20
      anchors.fill: parent
      Label {
        wrapMode: Text.WordWrap
        text: QmlJs.getPrintableDirPath(dirPath, homeDir)
        Layout.fillWidth: true
      }
      TextField {
        id: fileName
        focus: true
        placeholderText: i18n.tr("file.txt")
        Layout.fillWidth: true
        inputMethodHints: Qt.ImhNoPredictiveText

        // Enter key
        Keys.onReturnPressed: {
          visible = false
          onSubmit(fileName.text)
        }
      }
    }
  }
}
