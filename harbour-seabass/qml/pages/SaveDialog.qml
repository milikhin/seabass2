import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: root
    property string filePath: ''
    allowedOrientations: Orientation.All

    canAccept: true

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr('Discard changes?')
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin

                text: qsTr('Unsaved changes at %1 will be lost. Continue?').arg(filePath)
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
        }
    }
}
