.pragma library

var DEFAULT_FILE_PATH = Qt.resolvedUrl('../changelog.txt')

function getDefaultFilePath() {
    return Qt.application.arguments[2] || DEFAULT_FILE_PATH
}

/**
  * Extracts file name from a given path
  * @returns {string} - file name
  */
function getFileNameByPath(filePath) {
    return filePath.split('/').slice(-1)[0]
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
