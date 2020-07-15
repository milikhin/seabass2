import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import '.' as CustomComponents

ToolButton {
  id: root
  property string icon

  CustomComponents.Icon {
    anchors.centerIn: parent
    name: root.icon
  }
}
