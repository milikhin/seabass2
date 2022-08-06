import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    property alias name: nameField.text
    canAccept: nameField.text !== ''

    Column {
        width: parent.width

        DialogHeader {
            acceptText: qsTr('Create')
            title: qsTr('Create new file')
        }

        TextField {
            id: nameField
            width: parent.width
            placeholderText: "file.txt"
            label: "File name"
            focus: true
        }
    }
}
