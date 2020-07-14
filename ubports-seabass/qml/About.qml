import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import './components/common' as CustomComponents

Item {
  id: root

  readonly property string sourceUrl: 'github.com/milikhin/seabass2'
  property string version

  ColumnLayout {
    anchors.fill: parent

    CustomComponents.ToolBar {
      Layout.fillWidth: true

      hasLeadingButton: true
      onLeadingAction: pageStack.pop()
      title: i18n.tr("About")
      subtitle: "Seabass v%1".arg(version)
    }

    ListView {
      id: view
      Layout.fillWidth: true
      Layout.fillHeight: true

      readonly property var items: [
        {
          title: 'Seabass2',
          subtitle: 'Copyright (c) 2020, Mikhail Milikhin, MIT license',
          text: i18n.tr('Click here to open project page and find docs, support, donation options and list of contributors!'),
          url: 'https://github.com/milikhin/seabass2'
        },
        {
          title: 'Ace editor',
          text: 'Copyright (c) 2010, Ajax.org B.V., BSD license',
          url: 'https://github.com/ajaxorg/ace'
        },
        {
          title: 'Babel',
          text: 'Copyright (c) 2014-present Sebastian McKenzie and other contributors, MIT license',
          url: 'https://github.com/babel/babel'
        },
        {
          title: 'Clickable',
          text: 'Copyright (C) 2020 Brian Douglass, GNU GPLv3 license',
          url: 'https://gitlab.com/clickable/clickable'
        },
        {
          title: 'EditorConfig Python Core',
          text: 'Copyright (c) 2011-2018 EditorConfig Team, including Hong Xu and Trey Hunner, BSD license',
          url: 'https://github.com/editorconfig/editorconfig-core-py'
        },
        {
          title: 'inotify-simple',
          text: 'Copyright (c) 2016, Chris Billington, BSD license',
          url: 'https://github.com/chrisjbillington/inotify_simple'
        },
        {
          title: 'JavaScript-MD5',
          text: 'Copyright (c) 2011 Sebastian Tschan, https://blueimp.net, MIT license',
          url: 'https://github.com/blueimp/JavaScript-MD5'
        },
        {
          title: 'Jest',
          text: 'Copyright (c) Facebook, Inc. and its affiliates, MIT license',
          url: 'https://github.com/facebook/jest'
        },
        {
          title: 'PyOtherSide',
          text: 'Copyright (c) 2011, 2013-2020, Thomas Perl <m@thp.io>, ISC license',
          url: 'https://github.com/thp/pyotherside'
        },
        {
          title: 'UUID JavaScript Module',
          text: 'Copyright (c) 2010-2020 Robert Kieffer and other contributors, MIT license',
          url: 'https://github.com/uuidjs/uuid'
        },
        {
          title: 'webpack and webpack-contrib packages',
          text: 'Copyright JS Foundation and other contributors, MIT license',
          url: 'https://github.com/webpack/webpack'
        }
      ]
      model: items
      delegate: MouseArea {
        width: view.width
        height: listContent.height
        onClicked: Qt.openUrlExternally(view.items[index].url)

        Column {
          id: listContent
          width: parent.width

          Rectangle {
            width: parent.width
            height: Suru.units.gu(1)
          }
          Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Suru.units.gu(1)
            anchors.rightMargin: Suru.units.gu(1)
            text: view.items[index].title
            elide: Label.ElideRight
            Suru.textStyle: Suru.PrimaryText
          }
          Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Suru.units.gu(1)
            anchors.rightMargin: Suru.units.gu(1)
            text: view.items[index].subtitle || ''
            elide: Label.ElideRight
            visible: !!view.items[index].subtitle
            height: view.items[index].subtitle ? undefined : 0
            Suru.textStyle: Suru.SecondaryText
          }
          Label {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Suru.units.gu(1)
            anchors.rightMargin: Suru.units.gu(1)
            text: view.items[index].text
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            Suru.textStyle: Suru.TertiaryText
          }
          Rectangle {
            width: parent.width
            height: Suru.units.gu(1)
          }
          Rectangle {
            width: parent.width
            height: Suru.units.dp(1)
            color: Suru.neutralColor
          }
        }
      }
    }
  }
}
