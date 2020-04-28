.pragma library

function readFile(filePath, callback) {
    var request = new XMLHttpRequest()
    request.open('GET', filePath)
    request.onreadystatechange = function(event) {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status >= 200 && request.status <= 400) {
                return callback(null, request.responseText)
            }

            callback(request.responseText)
        }
    }
    request.onerror = function(err) {
        callback(err.message)
    }
    request.send();
}

function writeFile(filePath, content, callback) {
    var request = new XMLHttpRequest();
    request.open("PUT", filePath);
    request.onreadystatechange = function(event) {
        if (request.readyState === XMLHttpRequest.DONE) {
            if (request.status >= 200 && request.status <= 400) {
                return callback(null)
            }

            callback(request.responseText)
        }
    }
    request.onerror = function(err) {
        callback(err.message)
    }

    request.send(content);
}
