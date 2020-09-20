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
    }
  }
}
