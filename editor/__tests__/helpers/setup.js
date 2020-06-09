/* globals beforeEach, jest */
beforeEach(() => {
  navigator.qt = {
    postMessage: jest.fn()
  }

  delete window.location
  window.location = { assign: jest.fn() }
  window.scrollTo = jest.fn()

  document.body.innerHTML = `
    <div id="welcome"></div>
    <div id="root" style="height: 100px; width: 100px;"></div>
  `
})
