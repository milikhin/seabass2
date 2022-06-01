import QtQuick 2.2
import Sailfish.Silica 1.0

Item {
    id: root

    property bool readOnly
    property bool readOnlyEnabled
    property bool hasRedo
    property bool hasUndo

    signal undo()
    signal redo()
    signal toggleReadOnly
    signal navigateLeft()
    signal navigateRight()
    signal navigateUp()
    signal navigateDown()
    signal navigateLineStart()
    signal navigateLineEnd()
    signal navigateFileStart()
    signal navigateFileEnd()

    width: parent.width
    height: parent.height

    SilicaFlickable {
        contentWidth: panelRow.childrenRect.width;
        height: parent.height
        width: parent.width

        HorizontalScrollDecorator {}
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id: panelRow
            anchors.verticalCenter: parent.verticalCenter

            IconButton {
                enabled: root.hasUndo
                icon.source: "image://theme/icon-m-back"
                onClicked: root.undo()
            }

            IconButton {
                enabled: root.hasRedo
                icon.source: "image://theme/icon-m-forward"
                onClicked: root.redo()
            }

            IconButton {
                icon.source: "image://theme/icon-m-left"
                onClicked: root.navigateLeft()
                onPressAndHold: root.navigateLineStart()
            }

            IconButton {
                icon.source: "image://theme/icon-m-right"
                onClicked: root.navigateRight()
                onPressAndHold: root.navigateLineEnd()
            }

            IconButton {
                icon.source: "image://theme/icon-m-up"
                onClicked: root.navigateUp()
                onPressAndHold: root.navigateFileStart()
            }

            IconButton {
                icon.source: "image://theme/icon-m-down"
                onClicked: root.navigateDown()
                onPressAndHold: root.navigateFileEnd()
            }

            TextSwitch {
                text: qsTr("Read only")
                width: childrenRect.width + Theme.paddingLarge
                enabled: root.readOnlyEnabled
                checked: root.readOnly
                // disable automaticCheck, so that binding works
                automaticCheck: false
                onClicked: root.toggleReadOnly()
                Component.onCompleted: {
                    var label = children[1]
                    var description = children[2]
                    label.width = undefined
                    description.width = 0
                    description.visible = 0
                }
            }
        }
    }
}

