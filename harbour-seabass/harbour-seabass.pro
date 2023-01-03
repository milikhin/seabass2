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

copyQml.commands = $(COPY_DIR) $$PWD/../generic/qml/* $$PWD/qml/generic
copyPyCode.commands = $(COPY_DIR) $$PWD/../generic/py-backend $$PWD/qml
copyPyLibs1.commands = $(COPY_DIR) $$PWD/../generic/py-libs/inotify_simple $$PWD/qml/py-backend && rm $$PWD/qml/py-backend/inotify_simple/.git
copyPyLibs2.commands = $(COPY_DIR) $$PWD/../generic/py-libs/editorconfig-core-py/editorconfig $$PWD/qml/py-backend

first.depends = $(first) copyQml copyPyCode copyPyLibs1 copyPyLibs2
copyPyLibs1.depends = copyPyCode
copyPyLibs2.depends = copyPyCode
export(first.depends)
QMAKE_EXTRA_TARGETS += first copyQml copyPyCode copyPyLibs1 copyPyLibs2

DISTFILES += qml/harbour-seabass.qml \
    qml/components/Configuration.qml \
    qml/components/Tabs.qml \
    qml/components/TabsButton.qml \
    qml/components/Toolbar.qml \
    qml/generic/EditorApi.qml \
    qml/generic/EditorState.qml \
    qml/generic/FilesModel.qml \
    qml/generic/TabsModel.qml \
    qml/generic/utils.js \
    qml/html/dist \
    qml/cover/CoverPage.qml \
    qml/pages/About.qml \
    qml/pages/Editor.qml \
    qml/pages/ErrorDialog.qml \
    qml/pages/Files.qml \
    qml/pages/NewFile.qml \
    qml/pages/SaveDialog.qml \
    qml/pages/Settings.qml \
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
