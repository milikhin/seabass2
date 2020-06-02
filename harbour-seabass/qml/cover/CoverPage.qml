import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: root
    property string title: ''
    anchors.centerIn: parent

    Column {
        anchors.centerIn: parent

        Image {
            id: logo
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../logo.png"
        }

        Rectangle {
            height: Theme.paddingMedium
            width: parent.width
            color: "transparent"
        }

        Label {
            width: root.width - Theme.horizontalPageMargin * 2
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            visible: !!title
            id: label
            text: title
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

}
