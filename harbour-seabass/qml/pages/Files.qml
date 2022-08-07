import QtQuick 2.2
import Sailfish.Silica 1.0

import '../generic' as GenericComponents
import '../generic/utils.js' as QmlJs

Page {
    id: root
    property string homeDir
    signal opened (string filePath)

    allowedOrientations: Orientation.All

    GenericComponents.FilesModel {
        id: directoryModel
        rootDirectory: '/'
        prevDirectory: QmlJs.getNormalPath(homeDir)
        directory: homeDir
        showDotDot: true

        onErrorOccured: function(err) {
            displayError(err)
        }
    }

    SilicaListView {
        anchors.fill: parent

        header: PageHeader {
            title: qsTr('Files')
        }

        model: directoryModel.model
        delegate: ListItem {
            width: ListView.view.width
            height: Theme.itemSizeSmall

            onClicked: {
                if (isDir) {
                    directoryModel.directory = path
                } else {
                    opened(path)
                    pageStack.pop()
                }
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.rightMargin: Theme.horizontalPageMargin
                spacing: Theme.paddingMedium

                Icon {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter

                    source: isDir ? "image://theme/icon-m-file-folder" : "image://theme/icon-m-file-document"
                }
                Label {
                    width: parent.width - icon.width - Theme.paddingMedium
                    height: parent.height
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    text: name
                }
            }
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("New file...")
                onClicked: {
                    pageStack.push(newFile)
                }
            }
        }
    }

    Component {
        id: newFile
        NewFile {
//            acceptDestination: pageStack.previousPage()
//            acceptDestinationAction: PageStackAction.Pop
            onAccepted: {
                const callback = function() {
                    if (root.status === PageStatus.Active) {
                        pageStack.pop()
                        root.statusChanged.disconnect(callback)
                    }
                }
                root.opened(directoryModel.directory + '/' + name)
                root.statusChanged.connect(callback)
            }
        }
    }

    function displayError(errorMessage) {
        pageStack.completeAnimation()
        pageStack.push(Qt.resolvedUrl("ErrorDialog.qml"), {
            "text": errorMessage || error.message
        })
    }
}
