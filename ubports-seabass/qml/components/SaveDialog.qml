import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../generic/utils.js" as QmlJs

Item {
  property string fileName
  property var onSaved: function() {}
  property var onDismissed: function() {}

  function show(filePath, callbacks) {
    fileName = QmlJs.getFileNameByPath(filePath)
    onSaved = callbacks.onSaved
    onDismissed = callbacks.onDismissed
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      title: qsTr("Save changes in %1?").arg(fileName)
      text: qsTr("Changes will be lost if you close the file without saving.")
      Button {
        text: qsTr("Save")
        color: theme.palette.normal.positive
        onClicked: {
          PopupUtils.close(dialogue)
          onSaved()
        }
      }
      Button {
        text: qsTr("Close")
        color: theme.palette.normal.negative
        onClicked: {
          PopupUtils.close(dialogue)
          onDismissed()
        }
      }
      Button {
        text: qsTr("Cancel")
        onClicked: {
          PopupUtils.close(dialogue)
        }
      }
    }
  }
}
