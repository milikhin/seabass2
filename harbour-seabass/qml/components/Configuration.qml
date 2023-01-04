import QtQuick 2.0
import Nemo.Configuration 1.0

Item {
    property alias isToolbarVisible: configToolbarVisible.value
    property alias fontSize: configFontSize.value
    property alias useWrapMode: configUseWrapMode.value

    ConfigurationValue {
        id: configToolbarVisible
        key: "/apps/harbour-seabass/settings/is_toolbar_visible"
        defaultValue: true
    }

    ConfigurationValue {
        id: configFontSize
        key: "/apps/harbour-seabass/settings/font_size"
        defaultValue: 12
    }

    ConfigurationValue {
        id: configUseWrapMode
        key: "/apps/harbour-seabass/settings/soft_wrap_enabled"
        defaultValue: true
    }
}
