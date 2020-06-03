import QtQuick 2.9
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import Ubuntu.Components.Themes 1.3
import QtQuick.Layouts 1.3

Toolbar {
  signal tabBtnClicked()
  signal leftArrowClicked()
  signal rightArrowClicked()
  signal upArrowClicked()
  signal downArrowClicked()

  leadingActionBar.numberOfSlots: 5
  leadingActionBar.actions: [
    Action {
      iconName: 'go-down'
      text: i18n.tr('Down arrow')
      onTriggered: downArrowClicked()
    },
    Action {
      iconName: 'go-up'
      text: i18n.tr('Up arrow')
      onTriggered: upArrowClicked()
    },
    Action {
      iconName: 'go-next'
      text: i18n.tr('Right arrow')
      onTriggered: rightArrowClicked()
    },
    Action {
      iconName: 'go-previous'
      text: i18n.tr('Left arrow')
      onTriggered: leftArrowClicked()
    },
    Action {
      iconName: 'keyboard-tab'
      text: i18n.tr('Tab')
      onTriggered: tabBtnClicked()
    }
  ]
}