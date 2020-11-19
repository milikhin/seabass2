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

    Column {
      Layout.fillWidth: true
      Layout.fillHeight: true
      spacing: Suru.units.gu(1)

      Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Suru.units.gu(1)
        anchors.rightMargin: Suru.units.gu(1)
        spacing: Suru.units.gu(1)

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
        spacing: Suru.units.gu(1)

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
        spacing: Suru.units.gu(1)

        ColumnLayout {
          width: parent.width
          spacing: Suru.units.gu(1)

          Label {
            Layout.fillWidth: true
            text: i18n.tr(
              "You can create and build projects for UBports from within the Seabass using Clickable."
            )
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
          }

          Label {
            Layout.fillWidth: true
            text: i18n.tr(
              "In order to execute Clickable Seabass requires a special Libertine container " +
              "with build tools to be created first. " +
              "Once the container is created (its ID is `seabass2-build`) you can manage it as usual " +
              "using `libertine-container-manager` or via the System Settings. "
            )
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
          }

          Label {
            Layout.fillWidth: true
            text: i18n.tr(
              "Should anything goes wrong with container feel free to delete and recreate it once again."
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
          text: i18n.tr(buildContainerReady
            ? hasBuildContainer
              ? "ready"
              : "not exists"
            : "busy...")
        }
      }

      Row {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Suru.units.gu(1)
        anchors.rightMargin: Suru.units.gu(1)
        spacing: Suru.units.gu(1)

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
