.pragma library

function getDefaultFilePath() {
    return Qt.application.arguments[2] || ''
}

function getNormalPath(filePath) {
  return filePath[filePath.length - 1] === '/'
    ? filePath.slice(0, -1)
    : filePath
}

function getShortDirName(filePath, homeUrl) {
  var dirPath = getNormalPath(filePath)
  var dirName = dirPath
    .split('/')
    .slice(0, -1)
    .join('/') + '/'
  var homeDir = homeUrl.toString().replace('file://', '')

  if (dirName.indexOf(homeDir) === 0) {
    return dirName.replace(homeDir, '~')
  }

  return dirName
}

/**
  * Extracts file name from a given path
  * @returns {string} - file name
  */
function getFileNameByPath(filePath) {
    return filePath.split('/').slice(-1)[0]
}

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
                return callback(new Error('Error writing file'))
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
