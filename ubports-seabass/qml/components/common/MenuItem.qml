import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import '.' as CustomComponents

MenuItem {
  id: root
  property string iconName
  height: visible ? undefined : 0

  contentItem: RowLayout {
    anchors.fill: parent
    anchors.leftMargin: Suru.units.gu(1)

    CustomComponents.Icon {
      name: root.iconName
      Layout.preferredWidth: Suru.units.gu(2)
      Layout.preferredHeight: Suru.units.gu(2)
      Layout.leftMargin: Suru.units.gu(1)
      Layout.rightMargin: Suru.units.gu(1)
    }
    Label {
      Layout.fillWidth: true
      Layout.fillHeight: true
      verticalAlignment: Qt.AlignVCenter
      text: root.text
      elide: Label.ElideRight
    }
  }
}
