import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3

Page {
  id: root

  readonly property string sourceUrl: 'github.com/milikhin/seabass2'
  property string version

  header: PageHeader {
    title: i18n.tr("About")
    subtitle: "Seabass v%1".arg(version)

    trailingActionBar {
      actions: [
        Action {
          iconName: "like"
          text: i18n.tr("Feed the Seabass!")
          onTriggered: Qt.openUrlExternally("https://github.com/milikhin/seabass2")
        }
      ]
    }
  }

  ColumnLayout {
    anchors.top: header.bottom
    anchors.bottom: root.bottom
    anchors.left: root.left
    anchors.right: root.right

    ListView {
      id: view
      Layout.fillWidth: true
      Layout.fillHeight: true
      readonly property var items: [
        {
          title: 'Seabass2',
          subtitle: 'Copyright (c) 2020, Mikhael Milikhin, MIT license',
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
      delegate: ListItem {
        height: itemLayout.height + (divider.visible ? divider.height : 0)
        ListItemLayout {
          id: itemLayout
          title.text: view.items[index].title
          subtitle.text: view.items[index].subtitle || ''
          summary.text: view.items[index].text
          summary.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
          summary.maximumLineCount: -1
          ProgressionSlot {}
        }
        onClicked: Qt.openUrlExternally(view.items[index].url)
      }
    }
  }
}
