import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../generic/utils.js" as QmlJs

Item {
  id: root
  property string title
  property string text: ''
  property string okColor: theme.palette.normal.positive
  property string okText: i18n.tr("Ok")
  property var onOk: Function.prototype
  property var onCancel: Function.prototype


  function show(options) {
    onOk = options.onOk
    onCancel = options.onCancel || Function.prototype
    text = options.text
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      text: root.text
      title: root.title
      Button {
        text: okText
        color: okColor
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
