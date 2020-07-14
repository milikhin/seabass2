import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import '.' as CustomComponents

MenuItem {
  id: root
  property string icon

  contentItem: RowLayout {
    anchors.fill: parent
    anchors.leftMargin: Suru.units.gu(1)

    CustomComponents.Icon {
      name: root.icon
    }
    Label {
      Layout.fillWidth: true
      text: root.text
      elide: Label.ElideRight
    }
  }
}
