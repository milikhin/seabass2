# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-seabass

CONFIG += sailfishapp_qml

DISTFILES += qml/harbour-seabass.qml \
    qml/components/TabsButton.qml \
    qml/components/Toolbar.qml \
    qml/generic/EditorApi.qml \
    qml/generic/EditorState.qml \
    qml/generic/TabsModel.qml \
    qml/generic/utils.js \
    qml/html/dist \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/Editor.qml \
    qml/pages/ErrorDialog.qml \
    qml/pages/SaveDialog.qml \
    qml/py-backend \
    rpm/harbour-seabass.changes.in \
    rpm/harbour-seabass.changes.run.in \
    rpm/harbour-seabass.spec \
    rpm/harbour-seabass.yaml \
    translations/*.ts \
    harbour-seabass.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-seabass-de.ts
TRANSLATIONS += translations/harbour-seabass-nl.ts
TRANSLATIONS += translations/harbour-seabass-sv.ts
