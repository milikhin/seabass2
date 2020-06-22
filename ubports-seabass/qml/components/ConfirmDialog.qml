import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../generic/utils.js" as QmlJs

Item {
  id: root
  property var onOk: function() {}
  property var onCancel: function() {}
  property string text: ''

  function show(options) {
    onOk = options.onOk
    onCancel = options.onCancel || function() {}
    text = options.text
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      text: root.text
      title: i18n.tr("Creating build container")
      Button {
        text: i18n.tr("Ok")
        color: theme.palette.normal.positive
        onClicked: {
          PopupUtils.close(dialogue)
          onOk()
        }
      }
      Button {
        text: i18n.tr("Cancel")
        onClicked: {
          PopupUtils.close(dialogue)
          onCancel()
        }
      }
    }
  }
}
