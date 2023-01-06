import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import "../../generic/utils.js" as QmlJs

Item {
  property string dirPath
  property string homeDir: ''
  property var onSubmit: function() {}

  function show(path, handler) {
    dirPath = QmlJs.getPrintableDirPath(path, homeDir)
    onSubmit = handler
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      title: i18n.tr("Create new file")
      text: dirPath
      TextField {
        id: fileName
        focus: true
        placeholderText: i18n.tr("file.txt")
        inputMethodHints: Qt.ImhNoPredictiveText
        // Enter key
        Keys.onReturnPressed: {
          PopupUtils.close(dialogue)
          onSubmit(fileName.text)
        }
      }
      Button {
        enabled: fileName.text !== ''
        text: i18n.tr("Create")
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
