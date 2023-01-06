import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import "../generic/utils.js" as QmlJs

Item {
  property string message: i18n.tr('unknown error')

  function show(errorMsg) {
    message = errorMsg
    PopupUtils.open(dialog)
  }

  Component {
    id: dialog

    Dialog {
      id: dialogue
      title: i18n.tr('Error occured')
      text: message
      Button {
        text: i18n.tr("Close")
        onClicked: {
          PopupUtils.close(dialogue)
        }
      }
    }
  }
}
