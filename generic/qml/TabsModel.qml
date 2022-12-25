import QtQml.Models 2.2
import "./utils.js" as QmlJs

/**
 * @typedef Tab
 * @property {string} id - unique tab ID
 * @property {string} title - tab's title
 * @property {string} subTitle - tab's subtitle
 * @property {string} [filePath] - full file path
 * @property {boolean} [isBusy] - busy state flag
 * @property {boolean} [isTerminal] - terminal output flag
 */

// Represents opened tabs
ListModel {
  property int currentIndex: -1
  property var currentTab: currentIndex === -1 ? undefined : get(currentIndex)
  signal tabAdded(var tab, var options)
  signal tabClosed(string filePath)

  function listFiles() {
    var fileTabs = []
    for (var i = 0; i < count; i++) {
      var tab = get(i)
      if (tab.isTerminal) {
        continue
      }

      fileTabs.push(tab)
    }
    return fileTabs
  }

  function getIndex(id) {
    for (var i = 0; i < count; i++) {
      var item = get(i)
      if (item.id === id) {
        return i
      }
    }
  }

  function getTab(id) {
    const tabIndex = getIndex(id)
    return get(tabIndex)
  }

  function openTerminal(tabId, title, subTitle) {
    return open({
      id: tabId,
      title: title,
      subTitle: subTitle,
      isTerminal: true,
    })
  }

  function open(options) {
    var existingTabIndex = getIndex(options.id)
    if (existingTabIndex !== undefined) {
      currentIndex = existingTabIndex
      return existingTabIndex
    }

    var currentTab = {
      id: options.id,
      title: options.title,
      subTitle: options.subTitle,
      uniqueTitle: options.title,
      isTerminal: options.isTerminal || false,

      filePath: options.filePath,
      isBusy: false,
      hasChanges: false,
      lastOpened: options.doNotActivate ? undefined : Date.now()
    }
    append(currentTab)
    tabAdded(currentTab, {
      createIfNotExists: !options.isRestored,
      doNotActivate: options.doNotActivate
    })
    _updateTabNames()

    if (!options.doNotActivate) {
      currentIndex = count - 1
    }
  }

  function close(filePath) {
    var index = getIndex(filePath)
    remove(index, 1)
    tabClosed(filePath)
    _updateTabNames()

    if (index === currentIndex) {
      _updateCurrentIndex()
    }
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

  function _updateCurrentIndex() {
    currentIndex = -1

    const files = listFiles();
    if (files.length === 0) {
      return
    }

    const currentTab = files.sort(function (a, b) {
      return a.lastOpened - b.lastOpened
    })[0];
    currentIndex = getIndex(currentTab.id)
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
