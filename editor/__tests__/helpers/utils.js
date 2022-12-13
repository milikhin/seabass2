export function waitForSailfishApiMessage () {
  return new Promise(resolve => {
    document.addEventListener('framescript:action', resolve)
  })
}
