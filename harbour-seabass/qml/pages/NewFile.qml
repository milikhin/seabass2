import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {
    id: root
    property alias name: nameField.text
    canAccept: name.length > 0
    allowedOrientations: Orientation.All

    Column {
        width: parent.width

        DialogHeader {
            acceptText: qsTr('Create')
            title: qsTr('Create new file')
        }

        TextField {
            id: nameField
            width: parent.width
            placeholderText: 'file.txt'
            label: qsTr('File name')
            focus: true

            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: 'image://theme/icon-m-enter-accept'
            EnterKey.onClicked: root.accept()
        }
    }
}
