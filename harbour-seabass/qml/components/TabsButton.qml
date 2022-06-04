import QtQuick 2.2
import Sailfish.Silica 1.0

IconButton {
    id: root
    property alias text: label.text

    icon.source: 'image://theme/icon-m-tabs'

    Label {
        id: label
        anchors {
            centerIn: parent
        }
        font.pixelSize: Theme.fontSizeExtraSmall
        font.bold: true
        color: down ? Theme.highlightColor : Theme.primaryColor
        horizontalAlignment: Text.AlignHCenter
    }
}
