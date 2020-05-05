import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
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
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !!title
            id: label
            text: title
            wrapMode: "WrapAtWordBoundaryOrAnywhere"
        }
    }

}
