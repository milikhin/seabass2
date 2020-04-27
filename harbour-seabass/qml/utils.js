.pragma library

function readFile(filePath, callback) {
    var request = new XMLHttpRequest()
    request.open('GET', filePath)
    request.onreadystatechange = function(event) {
        if (request.readyState === XMLHttpRequest.DONE) {
            callback(null, request.responseText)
        }
    }
    request.send();
}

function writeFile(filePath, content, callback) {
    var request = new XMLHttpRequest();
    request.open("PUT", filePath);
    request.onreadystatechange = function(event) {
        if (request.readyState === XMLHttpRequest.DONE) {
            callback(null)
        }
    }
    request.send(content);
}

function handleApiMessage(message) {
    switch (message.action) {
        case 'saveFile':
            return writeFile(message.data.filePath, message.data.content, Function.prototype)
    }
}
