/* globals addEventListener, sendAsyncMessage */
// register `QT` <--> `Web page` interaction
addEventListener('DOMContentLoaded', function (aEvent) {
  aEvent.originalTarget.addEventListener('framescript:action',
    function (aEvent) {
      sendAsyncMessage('webview:action', aEvent.detail)
    })
})
