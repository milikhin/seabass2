import QtQml.Models 2.2
import "./utils.js" as QmlJs

ListModel {
  function getIndex(filePath) {
    for (var i = 0; i < count; i++) {
      var item = get(i)
      if (item.filePath === filePath) {
        return i
      }
    }
  }

  function open(filePath) {
    var existingTabIndex = getIndex(filePath)
    if (existingTabIndex !== undefined) {
      return existingTabIndex
    }

    append({
      id: filePath,
      name: QmlJs.getFileNameByPath(filePath),
      hasChanges: false,

      filePath: filePath
    })
  }
}
