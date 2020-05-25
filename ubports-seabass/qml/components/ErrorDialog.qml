import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../generic/utils.js" as QmlJs

Item {
  property string message: qsTr('unknown error')

  function show(errorMsg) {
    message = errorMsg
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      title: qsTr('Error occured')
      text: message
      Button {
        text: qsTr("Close")
        onClicked: {
          PopupUtils.close(dialogue)
        }
      }
    }
  }
}
