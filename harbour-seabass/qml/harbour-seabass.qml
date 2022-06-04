import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

import './generic/utils.js' as QmlJs

ApplicationWindow
{
    id: root
    property string coverTitle: qsTr('Welcome')

    initialPage: Component {
        Editor {
            onFilePathChanged: {
                root.coverTitle = filePath ? QmlJs.getFileName(filePath) : qsTr('Welcome')
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
