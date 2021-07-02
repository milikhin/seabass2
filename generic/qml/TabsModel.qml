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

      filePath: tabId
    })
  }

  function open(options) {
    var existingTabIndex = getIndex(options.id)
    if (existingTabIndex !== undefined) {
      return existingTabIndex
    }

    var currentTab = {
      id: options.id,
      hasChanges: false,
      isBusy: false,
      isInitial: options.isInitial,
      isTerminal: options.isTerminal || false,
      title: options.title,
      subTitle: options.subTitle,
      uniqueTitle: options.title,
      readOnly: options.isTerminal || options.readOnly || false,

      filePath: options.filePath
    }
    append(currentTab)
    tabAdded(currentTab)
    _updateTabNames()
  }

  function close(filePath) {
    var index = getIndex(filePath)
    remove(index, 1)
    tabClosed(filePath)
    _updateTabNames()
  }

  function patch(filePath, attributes) {
    var index = getIndex(filePath)
    var tab = get(index)
    for (var key in attributes) {
      tab[key] = attributes[key]
    }
    set(index, tab)
  }

  /**
   * Returns the number of path parts that are shared by the given files
   * Examples: - /foo/bar and /foo/baz share /foo ==> returns 2 (one for '/' and 'foo')
   *           - /foo/bar/baz and /foo/baz share /foo ==> returns 2
   *           - /foo/bar/baz and /baz share / ==> returns 1
   * @param {Object} files - files
   * @param {string}   files.path - /path/to/file
   * @param {string[]} files.parts - ['', 'path', 'to', 'file'] - /path/to/file split by '/' symbols
   * @returns {number} common dir prefix length
   */
  function _getCommonPrefixLength(files) {
    if (files.length === 1) {
      return -1
    }

    var commonPrefixLength = 0
    var foundDifference = false
    while(true) {
      if (commonPrefixLength > files[0].parts.length) {
        break
      }

      for (var i = 1; i < files.length; i++ ) {
        if (files[i].parts[commonPrefixLength] !== files[0].parts[commonPrefixLength]) {
          foundDifference = true
          break
        }
      }

      if (foundDifference) {
        break
      }

      commonPrefixLength++
    }

    return commonPrefixLength
  }

  /**
   * Groups tabs by file names
   * @returns {Object} - tab groups:
   *   {
   *     {string} filePath - /path/to/file
   *     {string[]} parts - ['', 'path', 'to', 'file'] - /path/to/file split by '/' symbols
   *   }
   */
  function _groupTabByFileNames() {
    var nameGroups = {}
    for (var i = 0; i < count; i++) {
      var tab = get(i)
      if (tab.isTerminal) {
        continue
      }

      var fileName = QmlJs.getFileName(tab.filePath)
      if (!nameGroups[fileName]) {
        nameGroups[fileName] = []
      }
      nameGroups[fileName].push({
        filePath: tab.filePath,
        parts: tab.filePath.split('/')
      })
    }
    return nameGroups
  }

  /**
   * Updates unique tab titles to make them unique across opened files
   * to prevent tabs visual naming collisions.
   * @returns {undefined}
   */
  function _updateTabNames() {
    const nameGroups = _groupTabByFileNames()
    for (var fileName in nameGroups) {
      var files = nameGroups[fileName]
      var commonPrefixLength = _getCommonPrefixLength(files)
      for (var i = 0; i < files.length; i++ ) {
        patch(files[i].filePath, {
          uniqueTitle: files[i].parts.slice(commonPrefixLength).join('/')
        })
      }
    }
  }
}
