import QtQuick 2.0
import './utils.js' as QmlJs

QtObject {
  // State
  property string filePath
  property string directory
  property bool hasChanges: false
  property bool hasUndo: false
  property bool hasRedo: false
  property bool isReadOnly: false
  property bool placeSearchOnTop: true

  // Colors
  property bool isDarkTheme: false
  property string backgroundColor: isDarkTheme ? QmlJs.colors.DARK_BACKGROUND : QmlJs.colors.LIGHT_BACKGROUND
  property string textColor: isDarkTheme ? QmlJs.colors.DARK_TEXT : QmlJs.colors.LIGHT_TEXT
  property string linkColor: textColor

  // Preferences
  property int fontSize: 12
  property bool useWrapMode: true

  // UI tweaks
  property int verticalHtmlOffset: 0

  Component.onCompleted: {
    isDarkThemeChanged.connect(loadTheme)
    linkColorChanged.connect(loadTheme)
    textColorChanged.connect(loadTheme)
    fontSizeChanged.connect(loadTheme)
    useWrapModeChanged.connect(loadTheme)
    verticalHtmlOffsetChanged.connect(updateViewport)
  }

  onIsReadOnlyChanged: {
    if (isReadOnly) {
      Qt.inputMethod.hide()
    }
  }

  function loadTheme() {
    api.postMessage('setPreferences', {
      isDarkTheme: isDarkTheme,
      backgroundColor: backgroundColor,
      highlightColor: linkColor,
      textColor: textColor,
      fontSize: fontSize,
      useWrapMode: useWrapMode,
      placeSearchOnTop: placeSearchOnTop
    })
  }

  function updateViewport() {
    api.postMessage('viewportChange', {
      verticalHtmlOffset: verticalHtmlOffset
    })
  }
}
