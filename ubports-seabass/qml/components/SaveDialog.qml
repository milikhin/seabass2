import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import "../generic/utils.js" as QmlJs

Item {
  property string fileName
  property var onSaved: function() {}
  property var onDismissed: function() {}

  function show(filePath, callbacks) {
    fileName = QmlJs.getFileName(filePath)
    onSaved = callbacks.onSaved
    onDismissed = callbacks.onDismissed
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      title: i18n.tr("Save changes in %1?").arg(fileName)
      text: i18n.tr("Changes will be lost if you close the file without saving.")
      Button {
        text: i18n.tr("Save")
        color: theme.palette.normal.positive
        onClicked: {
          PopupUtils.close(dialogue)
          onSaved()
        }
      }
      Button {
        text: i18n.tr("Close")
        color: theme.palette.normal.negative
        onClicked: {
          PopupUtils.close(dialogue)
          onDismissed()
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
