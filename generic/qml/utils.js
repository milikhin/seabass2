.pragma library

var colors = {
  // oneDark theme's background color
  DARK_BACKGROUND: '#282C34',
  // default codemirror theme's background color
  LIGHT_BACKGROUND: '#FFFFFF',
  // oneDark theme's default text color
  DARK_TEXT: '#ABB2BF',
  // default codemirror theme's text color
  LIGHT_TEXT: '#000000',
  // slightly darker than onDark background
  DARK_TOOLBAR_BACKGROUND: '#21252B',
  // slightly darker than default background
  LIGHT_TOOLBAR_BACKGROUND: '#E0E0E0',
  DARK_DIVIDER: '#21252B',
  // gutter's color from default theme
  LIGHT_DIVIDER: '#DDDDDD',
}

function getDefaultFilePath() {
  return Qt.application.arguments[2] || ''
}

/**
 * Returns directory path for the given file path
 * @param {string} filePath - /path/to/file OR file:///path/to/file
 * @returns {string} - directory path
 */
function getDirPath(filePath) {
  return getNormalPath(filePath).split('/').slice(0, -1).join('/') || '/'
}

/**
 * Extracts file name from a given path
 * @returns {string} - file name
 */
function getFileName(filePath) {
  return getNormalPath(filePath)
    .split('/')
    .slice(-1)[0]
}

/**
 * Returns path without trailing '/' and leading 'file://'
 * @param {string} path - /path/to/file
 * @returns {string} - normalized path
 */
function getNormalPath(path) {
  var normalPath = path.replace(/^file:\/\//, '')
  return normalPath.length > 1 && normalPath[normalPath.length - 1] === '/'
    ? path.slice(0, -1)
    : path
}

/**
 * Returns shortened version of dir path: with '~/' instead of home directory
 * @param {string} dirPath - /path/to/file OR file:///path/to/file
 * @param {string} homeDir - /home/<user>
 * @returns {string} - short dir path with trailing '/'
 */
function getPrintableDirPath(dirPath, homeDir) {
  var normalizedDir = getNormalPath(dirPath)
  var normalizedHome = getNormalPath(homeDir)
  if (normalizedDir.indexOf(normalizedHome) === 0) {
    return normalizedDir.replace(normalizedHome, '~') + '/'
  }

  return normalizedDir + '/'
}

function getPrintableFilePath(filePath, homeDir) {
  var normalizedPath = getNormalPath(filePath)
  var normalizedHome = getNormalPath(homeDir)

  return normalizedPath.replace(normalizedHome, '~')
}

/**
 *
 * @param {string} color1 - hex color
 * @param {string} color2 - hex color
 * @returns {boolean} - true if color1 is darker than color2, false otherwise
 */
function isDarker(color1, color2) {
  return __getColorDarkness(color1.toString()) < __getColorDarkness(color2.toString())

  function __getColorDarkness(color) {
    return parseInt(color.slice(1, 3), 16) +
      parseInt(color.slice(3, 5), 16) +
      parseInt(color.slice(5), 16)
  }
}

/**
  * Reads content of a file at the given path.
  * Async operation in Node.js callback notation
  *
  * @param {string} filePath - /path/to/file
  * @param {function} callback - callback function
  * @returns {undefined}
  */
function readFile(filePath, callback) {
    var request = new XMLHttpRequest()
    var sentSuccessfully = false;

    request.open('GET', filePath)
    request.onreadystatechange = function(event) {
        // The only way i've found to distinguish successful and failed fs write operations using XHR in QML
        //   is to check that request.readyState has got HEADERS_RECEIVED ("send has been called") value before the DONE value
        if (request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            sentSuccessfully = true
        }
        if (request.readyState === XMLHttpRequest.DONE) {
            if (!sentSuccessfully) {
                return callback(new Error('Error reading file'))
            }

            return callback(null, request.responseText)
        }
    }
    request.onerror = function(err) {
        callback(err)
    }
    request.send();
}

/**
  * Writes content to a file at the given path.
  * Async operation in Node.js callback notation
  *
  * @param {string} filePath - /path/to/file
  * @param {string} content - new file content
  * @param {function} callback - callback function
  * @returns {undefined}
  */
function writeFile(filePath, content, callback) {
    var request = new XMLHttpRequest();
    var sentSuccessfully = false;

    request.open("PUT", filePath);
    request.onreadystatechange = function(event) {
        // The only way i've found to distinguish successful and failed fs write operations using XHR in QML
        //   is to check that request.readyState has got HEADERS_RECEIVED ("send has been called") value before the DONE value
        if (request.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            sentSuccessfully = true
        }

        if (request.readyState === XMLHttpRequest.DONE) {
            if (!sentSuccessfully) {
                return callback(new Error('Error writing file'))
            }

            callback(null)
        }
    }
    request.onerror = function(err) {
        callback(err)
    }

    request.send(content);
}

function getFileIcon(fileName) {
  var extMatch = fileName.match(/\.([A-Za-z]+)$/)
  var ext = extMatch && extMatch[1]
  switch(ext) {
    case 'html':
      return 'text-html-symbolic'
    case 'css':
      return 'text-css-symbolic'
    case 'xml':
      return 'text-xml-symbolic'
    default:
      return 'text-x-generic-symbolic'
  }
}
