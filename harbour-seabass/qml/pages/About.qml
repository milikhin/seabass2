import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: root

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr('Seabass v%1').arg('0.4.0')
            }

            SectionHeader { text: qsTr("About") }
            LinkedLabel {
                plainText: qsTr("Seabass is developed by Mikhael Milikhin. Sources are available under MIT license: github.com/milikhin/seabass2")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                shortenUrl: true
            }

            SectionHeader { text: qsTr("Acknowledgements") }
            Label {
                text: qsTr("Ace editor, copyright (c) 2010, Ajax.org B.V., BSD license:")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            LinkedLabel {
                plainText: "github.com/ajaxorg/ace/blob/master/LICENSE"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                shortenUrl: true
            }
        }
    }
}
