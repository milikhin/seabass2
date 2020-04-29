import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    property string title: ''
    anchors.centerIn: parent

    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width

        Image {
            id: logo
            anchors.horizontalCenter: parent.horizontalCenter
            source: "../logo.png"
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: Theme.paddingMedium
            visible: !!title
            id: label
            text: title
        }
    }

}
