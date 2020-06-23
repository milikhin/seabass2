import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import QtQuick.Layouts 1.3

TabButton {
  id: root
  property real minLabelWidth: 0
  property real maxLabelWidth: Infinity
  property bool isActive: false
  property bool isBusy: false
  property bool hasChanges: false
  property real underlineWidth: units.gu(1) / 4

  readonly property real tabPadding: units.gu(1)
  readonly property real tabSpacing: units.gu(2)

  signal closed()

  property string backgroundColor: theme.palette.normal.background
  property string titleColor: isActive
    ? theme.palette.normal.backgroundText
    : theme.palette.normal.backgroundSecondaryText
  property string underlineColor: isActive
    ? theme.palette.normal.focus
    : theme.palette.normal.overlaySecondaryText
  property string accentColor: theme.palette.normal.focus

  width: tabLabel.width + closeIcon.width + tabHasChangesIcon.width + tabSpacing + tabPadding * 2
  background: Rectangle {
    color: backgroundColor
    border.width: 0
  }

  contentItem: RowLayout {
    spacing: 0
    height: parent.height
    width: parent.width

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.leftMargin: tabPadding
      Layout.rightMargin: tabSpacing

      Label {
        id: tabLabel
        anchors.verticalCenter: parent.verticalCenter
        color: titleColor
        elide: Text.ElideRight
        text: root.text
        Component.onCompleted: {
          tabLabel.width = Math.max(
            Math.min(contentWidth, root.maxLabelWidth),
            root.minLabelWidth
          )
          root.maxLabelWidthChanged.connect(function() {
            tabLabel.width = undefined
            tabLabel.width = Math.max(
              Math.min(contentWidth, root.maxLabelWidth),
              root.minLabelWidth
            )
          })
        }
      }
    }
    Label {
      id: tabHasChangesIcon
      text: '*'
      color: accentColor
      visible: hasChanges
    }

    Item {
      Layout.fillHeight: true
      Layout.rightMargin: tabPadding
      width: closeIcon.width

      Icon {
        id: closeIcon
        name: isBusy ? 'package-x-generic-symbolic' : 'close'
        height: tabLabel.height
        width: height
        anchors.verticalCenter: parent.verticalCenter
        color: isBusy ? accentColor : underlineColor
        opacity: isBusy ? 0.25 : 1

        NumberAnimation on opacity {
          id: busyAnimation
          running: isBusy
          loops: Animation.Infinite
          from: 0.25
          to: 0.85
          duration: 3000
        }
      }
      MouseArea {
        enabled: !isBusy
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: closed()
      }
    }
  }
  Rectangle {
    height: underlineWidth
    x: 0
    y: parent.height - height
    width: parent.width
    color: underlineColor
  }
}
