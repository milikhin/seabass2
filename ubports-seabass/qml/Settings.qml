import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import QtQml.Models 2.2
import Qt.labs.settings 1.0

import "./components/common" as CustomComponents
import "./constants.js" as Constants

Item {
  id: settingsPage
  property string version
  property bool buildContainerReady: false
  property bool hasBuildContainer: false
  signal containerCreationStarted()

  readonly property string stateReady: i18n.tr("ready")
  readonly property string stateBusy: i18n.tr("busy...")
  readonly property string stateNotExists: i18n.tr("not exists")

  ColumnLayout {
    anchors.fill: parent
    spacing: Suru.units.gu(1)

    CustomComponents.ToolBar {
      Layout.fillWidth: true

      hasLeadingButton: true
      onLeadingAction: pageStack.pop()
      title: i18n.tr("Settings")
      subtitle: "Seabass v%1".arg(version)
    }

    ScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

      Column {
        width: settingsPage.width
        spacing: Suru.units.gu(1)

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          Label {
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            text: i18n.tr("User interface")
          }
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)
          spacing: Suru.units.gu(1)

          Label {
            anchors.verticalCenter: parent.verticalCenter
            text: i18n.tr("Theme:")
          }

          ComboBox {
            id: themeSelect
            model: ListModel {
              id: themeList
              Component.onCompleted: {
                append({ text: i18n.tr("System"), value: Constants.Theme.System })
                append({ text: "Suru Light", value: Constants.Theme.SuruLight })
                append({ text: "Suru Dark", value: Constants.Theme.SuruDark })

                themeSelect.currentIndex = _getIndexByTheme(settings.theme)
              }

              function _getIndexByTheme(themeId) {
                return themeId
              }
            }
            textRole: "text"
            onCurrentIndexChanged: {
              settings.theme = themeList.get(currentIndex).value
            }
          }
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)
          spacing: Suru.units.gu(1)

          Label {
            anchors.verticalCenter: parent.verticalCenter
            text: i18n.tr("Font size, CSS px:")
          }

          TextField {
            maximumLength: 2
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            Component.onCompleted: {
              text = settings.fontSize
            }
            onTextChanged: {
              const value = parseInt(text)
              if (isNaN(value) || value < 0) {
                return
              }

              settings.fontSize = value
            }
          }
        }

        Rectangle {
          width: parent.width
          height: Suru.units.dp(1)
          color: Suru.neutralColor
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          Label {
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            text: i18n.tr("Build container")
          }
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          ColumnLayout {
            width: parent.width
            spacing: Suru.units.gu(1)

            Label {
              Layout.fillWidth: true
              text: i18n.tr(
                "You can use the Seabass to build projects with Clickable."
              )
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Label {
              Layout.fillWidth: true
              text: i18n.tr(
                "In order to execute Clickable, Seabass requires a special Libertine container to be created first. " +
                "Once the container is created you can manage it as usual " +
                "using `libertine-container-manager` (container ID is `seabass2-build`) or via the System Settings."
              )
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Label {
              Layout.fillWidth: true
              text: i18n.tr(
                "Should anything goes wrong with the container you can delete and recreate it once again."
              )
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
          }
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          ColumnLayout {
            width: parent.width
            spacing: Suru.units.gu(1)

            Label {
              Layout.fillWidth: true
              font.bold: true
              text: i18n.tr(
                "Notes:"
              )
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            RowLayout {
              Layout.fillWidth: true
              Label {
                Layout.maximumWidth: parent.parent.width - Suru.units.gu(3)
                text: i18n.tr(
                  "• To build a project you need to open a corresponding clickable.json file and click the 'Build' button:"
                )
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
              }
              Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Suru.units.gu(2)
                Layout.alignment: Qt.AlignVCenter
                CustomComponents.Icon {
                  name: 'package-x-generic-symbolic'
                }
              }
            }

            Label {
              Layout.fillWidth: true
              text: i18n.tr(
                "• Project files should be located inside ~/Downloads or ~/Documents directories. " +
                "These directories are automatically mounted into Libertine containers. " +
                "Alternatively you can create additional bind mounts manually."
              )
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            Label {
              Layout.fillWidth: true
              text: i18n.tr(
                "• clickable.json file should be named 'clickable.json'."
              )
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
          }
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)
          spacing: Suru.units.gu(1)

          Label {
            anchors.verticalCenter: parent.verticalCenter
            text: i18n.tr("Container status:")
          }

          Label {
            anchors.verticalCenter: parent.verticalCenter
            font.bold: true
            text: buildContainerReady
              ? hasBuildContainer
                ? stateReady
                : stateNotExists
              : stateBusy
          }
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          Button {
            visible: !hasBuildContainer
            text: i18n.tr("Create build container")
            enabled: buildContainerReady
            onClicked: {
              containerCreationStarted()
            }
          }
        }
      }
    }
  }
}
