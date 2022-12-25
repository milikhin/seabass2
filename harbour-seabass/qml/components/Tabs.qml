import QtQuick 2.2
import Sailfish.Silica 1.0

Drawer {
    id: root
    property int currentIndex: -1
    property string title: 'Tabs'
    property alias model: list.model

    signal selected(string id)
    signal closed(string id)
    signal closedAll()

    background: SilicaListView {
        id: list
        anchors.fill: parent
        header: PageHeader {
            title: root.title
        }

        PullDownMenu {
            MenuItem {
                text: "Close all"
                onClicked: {
                    root.closedAll()
                }
            }
        }
        VerticalScrollDecorator {}

        delegate: ListItem {
            id: listItem
            onClicked: {
                root.selected(model.id)
            }
            menu: Component {
                ContextMenu {
                    MenuItem {
                        text: "Close"
                        onClicked: {
                            root.closed(model.id)
                        }
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                text: model.hasChanges ? ('* ' + model.title) : model.title
                anchors.verticalCenter: parent.verticalCenter
                highlighted: listItem.highlighted
            }
        }
    }
}
