import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

import './components/common' as CustomComponents

Item {
    id: settingsPage

    // readonly property string sourceUrl: 'github.com/milikhin/seabass2'

    ColumnLayout {
        anchors.fill: parent

        CustomComponents.ToolBar {
            id: header
            Layout.fillWidth: true

            hasLeadingButton: true
            onLeadingAction: pageStack.pop()
            title: i18n.tr("Settings")
            subtitle: i18n.tr("for seabass2")
        }

        Flickable {
            id: settingsFlickable
            clip: true
            flickableDirection: Flickable.AutoFlickIfNeeded

            anchors {
                topMargin: header.height
                fill: parent
            }

            contentHeight: settingsColumn.childrenRect.height

            Column {
                id: settingsColumn

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                spacing: units.gu(1)

                Label {
                    text: i18n.tr("Select theme:")
                }

                Button {
                    text: i18n.tr("System theme")
                    onClicked: {
                        settings.selectedTheme = "System";
                        root.setCurrentTheme();
                    }
                }
                Button {
                    text: i18n.tr("Ambiance theme")
                    onClicked: {
                        settings.selectedTheme = "Ambiance";
                        root.setCurrentTheme();
                    }
                }
                Button {
                    text: i18n.tr("Suru-dark theme")
                    onClicked: {
                        settings.selectedTheme = "Suru-dark";
                        root.setCurrentTheme();
                    }
                }
            }
        }
    }
}
