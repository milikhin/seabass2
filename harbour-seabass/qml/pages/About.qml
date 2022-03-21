import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: root
    allowedOrientations: Orientation.All

    SilicaListView {
        anchors.fill: parent
        header: PageHeader {
            id: header
            title: qsTr('Seabass v%1').arg('0.7.4')
        }
        model: ListModel {
            ListElement {
                text: "Seabass2, Copyright (c) 2020, Mikhail Milikhin, MIT license:"
                url: "github.com/milikhin/seabass2"
            }
            ListElement {
                text: "Codemirror, Copyright (C) 2018 by Marijn Haverbeke <marijnh@gmail.com>, Adrian Heine <mail@adrianheine.de>, and others, MIT license:"
                url: "github.com/ajaxorg/ace"
            }
            ListElement {
                text: "Babel, Copyright (c) 2014-present Sebastian McKenzie and other contributors, MIT license:"
                url: "github.com/babel/babel"
            }
            ListElement {
                text: 'EditorConfig Python Core, Copyright (c) 2011-2018 EditorConfig Team, including Hong Xu and Trey Hunner, BSD license:'
                url: 'github.com/editorconfig/editorconfig-core-py'
            }
            ListElement {
              text: 'inotify-simple, Copyright (c) 2016, Chris Billington, BSD license'
              url: 'github.com/chrisjbillington/inotify_simple'
            }
            ListElement {
                text: "JavaScript-MD5, Copyright (c) 2011 Sebastian Tschan, https://blueimp.net, MIT license:"
                url: "github.com/blueimp/JavaScript-MD5"
            }
            ListElement {
                text: "Jest, Copyright (c) Facebook, Inc. and its affiliates, MIT license:"
                url: "github.com/facebook/jest"
            }

            ListElement {
                text: "UUID JavaScript Module, Copyright (c) 2010-2020 Robert Kieffer and other contributors, MIT license:"
                url: "github.com/uuidjs/uuid"
            }
            ListElement {
                text: "webpack and webpack-contrib packages, Copyright JS Foundation and other contributors, MIT license:"
                url: "github.com/webpack/webpack"
            }
        }
        delegate: ListItem {
            contentHeight: itemText.height + itemUrl.height + Theme.paddingMedium

            width: root.width
            Label {
                id: itemText
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin

                text: model.text
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                color: Theme.highlightColor
            }
            LinkedLabel {
                id: itemUrl
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: itemText.bottom
                anchors.bottomMargin: Theme.paddingMedium

                plainText: url
                shortenUrl: true
                font.pixelSize: Theme.fontSizeSmall
            }
        }
    }
}
