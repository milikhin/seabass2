import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

import './generic/utils.js' as QmlJs

ApplicationWindow
{
    id: root
    property string defaultFilePath: QmlJs.getDefaultFilePath()
    property string coverTitle: defaultFilePath
        ? QmlJs.getFileName(defaultFilePath)
        : qsTr('Welcome')

    initialPage: Component {
        Editor {
            seabassFilePath: defaultFilePath
            onSeabassFilePathChanged: {
                root.coverTitle = QmlJs.getFileName(seabassFilePath)
            }
        }
    }
    cover: Component {
        CoverPage {
            title: coverTitle
        }
    }
    allowedOrientations: defaultAllowedOrientations
}
