import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.3
import Ubuntu.Components.Themes 1.3
import QtQuick.Controls 2.2

import Qt.labs.folderlistmodel 2.1

ListView {
  id: root
  property bool isPage: false
  property bool showHidden: false
  property string homeDir
  property real rowHeight: units.gu(4.5)

  readonly property string backgroundColor: theme.palette.normal.background
  readonly property string textColor: theme.palette.normal.backgroundText

  signal closed()
  signal fileCreationInitialised(string dirPath)
  signal fileSelected(string filePath)

  ScrollBar.vertical: ScrollBar {}

  header: PageHeader {
    title: i18n.tr("Files")
    subtitle: folderModel.folder.toString().replace('file://', '')
    navigationActions:[
      Action {
        visible: isPage
        iconName: "back"
        text: i18n.tr("Close")
        onTriggered: closed()
      }
    ]
    trailingActionBar {
      actions: [
        Action {
          visible: !isPage
          iconName: "close"
          text: i18n.tr("Close")
          onTriggered: closed()
        },
        Action {
          iconName: "add"
          text: i18n.tr("New file...")
          onTriggered: fileCreationInitialised(folderModel.folder.toString().replace('file://', ''))
        }
      ]
    }
  }
  model: folderModel
  delegate: ListItem {
    visible: isVisible()
    height: isVisible() ? rowHeight : 0
    color: backgroundColor

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: false
      onClicked: {
        if (fileIsDir) {
          return folderModel.folder = filePath
        }

        fileSelected(filePath)
      }

      RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)
        anchors.verticalCenter: parent.verticalCenter
        spacing: units.gu(1)

        Icon {
          height: parent.height
          name: fileIsDir ? 'folder-symbolic' : 'stock_document'
          color: textColor
        }
        Label {
          Layout.fillWidth: true
          Layout.fillHeight: true
          elide: Text.ElideRight
          text: fileName
          color: textColor
        }
      }
    }

    function isVisible() {
      return fileName !== '.'
    }
  }

  FolderListModel {
    id: folderModel
    rootFolder: homeDir
    folder: homeDir

    showDirsFirst: true
    showDotAndDotDot: true
    showHidden: true
    showOnlyReadable: true
  }
}
