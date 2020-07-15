import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
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
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      title: i18n.tr("Rename %1").arg(originalFileName)
      text: QmlJs.getPrintableDirPath(dirPath, homeDir)
      TextField {
        id: fileName
        focus: true
        placeholderText: i18n.tr("file.txt")
        text: originalFileName
        inputMethodHints: Qt.ImhNoPredictiveText
        // Enter key
        Keys.onReturnPressed: {
          PopupUtils.close(dialogue)
          onSubmit(fileName.text)
        }
      }
      Button {
        enabled: fileName.text !== ''
        text: i18n.tr("Rename")
        color: theme.palette.normal.positive
        onClicked: {
          PopupUtils.close(dialogue)
          onSubmit(fileName.text)
        }
      }
      Button {
        text: i18n.tr("Cancel")
        onClicked: {
          PopupUtils.close(dialogue)
        }
      }
    }
  }
}
