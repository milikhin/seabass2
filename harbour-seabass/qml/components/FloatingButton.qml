import QtQuick 2.2
import Sailfish.Silica 1.0

import '../generic/utils.js' as QmlJs

Rectangle {
    id: root
    property bool isDarkTheme
    property bool highlighed: false
    property alias icon: button.icon
    signal clicked()

    width: childrenRect.width
    height: childrenRect.height
    color: isDarkTheme
        ? QmlJs.colors.DARK_TOOLBAR_BACKGROUND
        : QmlJs.colors.LIGHT_TOOLBAR_BACKGROUND
    radius: Theme.dp(2)

    Button {
        id: button
        backgroundColor: Theme.rgba(Theme.highlightBackgroundColor,
            highlighed ? Theme.highlightBackgroundOpacity : 0)
        border.color: Theme.highlightBackgroundColor
        icon.color: highlighed ? Theme.highlightColor : Theme.primaryColor
        onClicked: root.clicked()
    }
}