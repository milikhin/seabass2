import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: root
    allowedOrientations: Orientation.All
    property bool useWrapMode
    property int fontSize

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            spacing: Theme.paddingLarge
            width: parent.width

            PageHeader {
                title: qsTr('Settings')
            }

            TextField {
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr('Font size, CSS px')
                text: fontSize
                onTextChanged: {
                    const newValue = parseInt(text)
                    if (!newValue || newValue < 0) {
                        return;
                    }

                    root.fontSize = newValue
                }
            }

            TextSwitch {
                text: qsTr('Soft wrap')
                description: qsTr('Automatically wrap long lines')
                checked: useWrapMode
                onCheckedChanged: {
                    root.useWrapMode = checked
                }
            }
        }
    }
}
