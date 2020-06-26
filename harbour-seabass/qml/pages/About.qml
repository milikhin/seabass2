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
                title: qsTr('Seabass v%1').arg('0.5.1')
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

            Label {
                text: qsTr("Babel, Copyright (c) 2014-present Sebastian McKenzie and other contributors, MIT license:")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            LinkedLabel {
                plainText: "github.com/babel/babel/blob/master/LICENSE"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                shortenUrl: true
            }

            Label {
                text: qsTr("JavaScript-MD5, Copyright (c) 2011 Sebastian Tschan, https://blueimp.net, MIT license:")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            LinkedLabel {
                plainText: "github.com/blueimp/JavaScript-MD5/blob/master/LICENSE.txt"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                shortenUrl: true
            }

            Label {
                text: qsTr("Jest, Copyright (c) Facebook, Inc. and its affiliates, MIT license:")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            LinkedLabel {
                plainText: "github.com/facebook/jest/blob/master/LICENSE"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                shortenUrl: true
            }

            Label {
                text: qsTr("UUID JavaScript Module, Copyright (c) 2010-2020 Robert Kieffer and other contributors, MIT license:")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            LinkedLabel {
                plainText: "github.com/uuidjs/uuid/blob/master/LICENSE.md"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                shortenUrl: true
            }

            Label {
                text: qsTr("webpack and webpack-contrib packages, Copyright JS Foundation and other contributors, MIT license:")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.highlightColor
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            LinkedLabel {
                plainText: "github.com/webpack/webpack/blob/master/LICENSE"
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
