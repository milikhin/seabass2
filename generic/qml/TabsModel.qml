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

  function openTerminal(tabId, title) {
    return open({
      id: tabId,
      name: title,
      readOnly: true,
      isTerminal: true,

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
      isTerminal: options.isTerminal || false,
      name: options.name || QmlJs.getFileName(options.filePath),
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
}
