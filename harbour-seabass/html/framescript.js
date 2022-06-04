/* globals addEventListener, sendAsyncMessage */
// register `QT` <--> `Web page` interaction
addEventListener('DOMContentLoaded', function (loadEvt) {
  loadEvt.originalTarget.addEventListener('framescript:action', function (evt) {
    sendAsyncMessage('webview:action', evt.detail)
  })
})
