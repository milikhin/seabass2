import QtQml.Models 2.2
import "./utils.js" as QmlJs

ListModel {
  signal tabAdded(var tab)
  signal tabClosed(string filePath)

  function getIndex(id) {
    for (var i = 0; i < count; i++) {
      var item = get(i)
      if (item.id === id) {
        return i
      }
    }
  }

  function openTerminal(tabId, title, subTitle) {
    return open({
      id: tabId,
      title: title,
      subTitle: subTitle,
      readOnly: true,
      isTerminal: true,
      isBusy: true,

      filePath: tabId
    })
  }

  function open(options) {
    var existingTabIndex = getIndex(options.id)
    if (existingTabIndex !== undefined) {
      return existingTabIndex
    }

    var tab = {
      id: options.id,
      hasChanges: false,
      isBusy: options.isTerminal || false,
      isTerminal: options.isTerminal || false,
      title: options.title,
      subTitle: options.subTitle,
      readOnly: options.isTerminal || options.readOnly || false,

      filePath: options.filePath
    }
    append(tab)
    tabAdded(tab)
  }

  function close(filePath) {
    var index = getIndex(filePath)
    remove(index, 1)
    tabClosed(filePath)
  }

  function patch(filePath, attributes) {
    var index = getIndex(filePath)
    var tab = get(index)
    for (var key in attributes) {
      tab[key] = attributes[key]
    }
    set(index, tab)
  }
}
