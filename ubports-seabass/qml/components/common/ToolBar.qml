import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import '.' as CustomComponents

ToolBar {
  z: 1
  property bool hasLeadingButton: false
  property string title
  property string subtitle
  property string leadingIcon
  default property alias content: row.children
  signal leadingAction()

  RowLayout {
    anchors.fill: parent

    CustomComponents.ToolButton {
      icon: leadingIcon || "back"
      visible: hasLeadingButton
      onClicked: leadingAction()
    }
    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.leftMargin: Suru.units.gu(1)

      Column {
        anchors.fill: parent
        Label {
          width: parent.width
          text: title
          height: parent.height * 0.6
          elide: Label.ElideRight
          horizontalAlignment: Qt.AlignHLeft
          verticalAlignment: Qt.AlignBottom
          Suru.textLevel: Suru.HeadingThree
          Suru.textStyle: Suru.PrimaryText
        }
        Label {
          width: parent.width
          text: subtitle
          elide: Label.ElideLeft
          horizontalAlignment: Qt.AlignHLeft
          verticalAlignment: Qt.AlignTop
          Suru.textLevel: Suru.Paragraph
          Suru.textStyle: Suru.TertiaryText
        }
      }
    }
    Row {
      id: row
    }
  }
}
