import QtQuick 2.9
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3

Rectangle {
    property bool isVertical: false

    Layout.fillWidth: !isVertical
    Layout.fillHeight: isVertical
    height: isVertical ? undefined : 1
    width: isVertical ? 1 : undefined
    color: Suru.neutralColor
    visible: keyboardExtension.visible
}