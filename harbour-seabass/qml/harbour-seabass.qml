import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

import './utils.js' as QmlJs

ApplicationWindow
{
    id: root
    property var defaultFile: QmlJs.getDefaultFile()
    property string coverTitle: defaultFile.fileName
    initialPage: Component {
        Editor {
            seabassFilePath: defaultFile.filePath
            seabassFileName: defaultFile.fileName
            seabassForceReadOnly: defaultFile.isReadOnly
            seabassIsReadOnly: defaultFile.isReadOnly
            onSeabassFileNameChanged: {
                root.coverTitle = seabassFileName
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
