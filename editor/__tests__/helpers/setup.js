/* globals beforeEach, jest */
beforeEach(() => {
  navigator.qt = {
    postMessage: jest.fn()
  }

  delete window.location
  window.location = { assign: jest.fn() }
})
