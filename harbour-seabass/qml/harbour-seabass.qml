import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "cover"

ApplicationWindow
{
    id: root
    property string coverTitle: ''
    initialPage: Component {
        Editor {
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
