import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import QtQuick.Layouts 1.3

Toolbar {
  signal tabBtnClicked()
  signal escBtnClicked()
  signal leftArrowClicked()
  signal rightArrowClicked()
  signal upArrowClicked()
  signal downArrowClicked()

  leadingActionBar.numberOfSlots: 6
  leadingActionBar.actions: [
    Action {
      iconName: 'go-down'
      onTriggered: downArrowClicked()
    },
    Action {
      iconName: 'go-up'
      onTriggered: upArrowClicked()
    },
    Action {
      iconName: 'go-next'
      onTriggered: rightArrowClicked()
    },
    Action {
      iconName: 'go-previous'
      onTriggered: leftArrowClicked()
    },
    Action {
      text: i18n.tr('Tab')
      onTriggered: tabBtnClicked()
    },
    Action {
      text: i18n.tr('Esc')
      onTriggered: escBtnClicked()
    }
  ]
  leadingActionBar.delegate: AbstractButton {
    id: toolbarButton
    anchors {
      top: parent.top
      bottom: parent.bottom
    }
    width: buttonsRow.width + units.gu(2)
    action: modelData

    style: Rectangle {
      color: "transparent"

      Connections {
        target: parent
        onPressedChanged: color = target.pressed
          ? theme.palette.normal.raised
          : "transparent"
      }

      Behavior on color {
        enabled: toolbarButton.pressed
        ColorAnimation {
          easing: UbuntuAnimation.StandardEasing
          duration: UbuntuAnimation.BriskDuration
        }
      }
    }

    RowLayout {
      id: buttonsRow
      spacing: units.gu(0.5)
      width: units.gu(4)
      anchors {
        top: parent.top
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
      }

      Icon {
        id: icon

        Layout.preferredWidth: units.gu(1.5)
        Layout.preferredHeight: Layout.preferredWidth
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

        name: action.iconName
        visible: action.iconName
        color: theme.palette.normal.backgroundText
      }

      Label {
        id: label

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        horizontalAlignment: Text.AlignHCenter
        text: action.text
        elide: Text.ElideRight
        visible: action.text
        color: theme.palette.normal.backgroundText
      }
    }
  }
}