import QtQuick 2.4
import QtQuick.Controls 2.2
import QtQuick.Controls.Suru 2.2
import QtQuick.Layouts 1.3
import QtQml.Models 2.2
import Qt.labs.settings 1.0

import "./generic/utils.js" as QmlJs

import "./components/common" as CustomComponents
import "./constants.js" as Constants

Item {
  id: root
  property string dirName
  property string homeDir
  property bool buildContainerReady: false
  property bool hasBuildContainer: false

  signal projectCreationRequested(string dirName, var options)

  ColumnLayout {
    anchors.fill: parent
    spacing: Suru.units.gu(1)

    CustomComponents.ToolBar {
      Layout.fillWidth: true

      hasLeadingButton: true
      onLeadingAction: pageStack.pop()
      title: i18n.tr("New Project")
      subtitle: QmlJs.getPrintableDirPath(dirName, homeDir)
    }

    ScrollView {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Column {
        width: root.width
        spacing: Suru.units.gu(2)

        Label {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)
          text: i18n.tr("Note: it is only possible to create new projects inside directories " +
              "that are mounted into Libertine containers " +
              "(only ~/Downloads and ~/Documents are mounted by default)")
          wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        GridLayout {
          id: grid
          columns: 2
          columnSpacing: Suru.units.gu(1)
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          Label {
            text: i18n.tr("Template:")
          }
          ComboBox {
            id: template
            model: ListModel {
              id: templateModel
              Component.onCompleted: {
                append({ text: "QML Only", value: 'pure-qml-cmake' })
                append({ text: "C++", value: 'cmake' })
                append({ text: "Python", value: 'python-cmake' })
                append({ text: "HTML", value: 'html' })
              }
            }
            textRole: "text"
            Component.onCompleted: {
              currentIndex = 0
            }
          }


          Label {
            text: i18n.tr("Title:")
          }
          RowLayout {
            Layout.fillWidth: true

            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true
              id: title
              placeholderText: 'App Title'
            }
          }

          Label {
            text: i18n.tr("Package name:")
          }
          RowLayout {
            Layout.fillWidth: true
            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true

              id: appName
              placeholderText: 'appname'
            }
          }


          Label {
            text: i18n.tr("Package namespace:")
          }
          RowLayout {
            Layout.fillWidth: true

            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true
              id: namespace
              placeholderText: 'yourname'
            }
          }


          Label {
            text: i18n.tr("Description:")
          }
          RowLayout {
            Layout.fillWidth: true

            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true
              wrapMode: Text.WrapAtWordBoundaryOrAnywhere

              id: description
              placeholderText: i18n.tr('A short description of your app')
            }
          }

          Label {
            text: i18n.tr("Maintainer Name:")
          }
          RowLayout {
            Layout.fillWidth: true

            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true

              id: name
              placeholderText: 'Your Full Name'
            }
          }

          Label {
            text: i18n.tr("Maintainer Email:")
          }
          RowLayout {
            Layout.fillWidth: true
            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true

              id: email
              placeholderText: 'email@domain.org'
            }
          }

          Label {
            text: i18n.tr("License:")
          }
          ComboBox {
            id: license
            model: ListModel {
              id: licenseModel
              Component.onCompleted: {
                append({ text: "GNU GPL v3", value: 'gpl3' })
                append({ text: "MIT", value: 'mit' })
                append({ text: "BSD", value: 'bsd' })
                append({ text: "ISC", value: 'isc' })
                append({ text: "Apache 2.0", value: 'apache' })
                append({ text: "Proprietary", value: 'proprietary' })
              }
            }
            Component.onCompleted: {
              currentIndex = 0
            }
            textRole: "text"
          }


          Label {
            text: i18n.tr("Copyright year:")
          }
          RowLayout {
            Layout.fillWidth: true

            TextField {
              Layout.maximumWidth: Suru.units.gu(40)
              Layout.fillWidth: true

              id: copyright
              placeholderText: new Date().getFullYear()
            }
          }


          Label {
            text: i18n.tr("Git tag versioning:")
          }
          Switch {
            id: gitTagVersioning
          }
        }

        Label {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)
          visible: !hasBuildContainer || !buildContainerReady
          text: !buildContainerReady
            ? i18n.tr("Please wait, the build container is busy...")
            : i18n.tr("Note: your device must support Libertine to create and build projects")
          wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        Row {
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: Suru.units.gu(1)
          anchors.rightMargin: Suru.units.gu(1)

          Button {
            text: i18n.tr("Create project")
            enabled: buildContainerReady
            onClicked: {
              var args = {
                title: title.text,
                name: appName.text,
                namespace: namespace.text,
                description: description.text,
                maintainer: name.text,
                mail: email.text,
                template: templateModel.get(template.currentIndex).value,
                license: licenseModel.get(license.currentIndex).value,
                'copyright-year': copyright.text,
                'git-tag-versioning': gitTagVersioning.checked
              }
              projectCreationRequested(dirName, args)
            }
          }
        }

        Row {
          height: Suru.units.gu(1)
          width: parent.width
        }
      }
    }
  }
}
