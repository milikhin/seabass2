/* globals jest */

export default () => ({
  activate: jest.fn(),
  destroy: jest.fn(),
  getContent: jest.fn(),
  getFilePath: jest.fn(),
  loadFile: jest.fn(),
  onChange: jest.fn(),
  redo: jest.fn(),
  setPreferences: jest.fn(),
  setSavedContent: jest.fn(),
  toggleReadOnly: jest.fn(),
  undo: jest.fn(),

  navigateDown: jest.fn(),
  navigateLeft: jest.fn(),
  navigateRight: jest.fn(),
  navigateUp: jest.fn(),
  navigateLineStart: jest.fn(),
  navigateLineEnd: jest.fn(),
  navigateFileStart: jest.fn(),
  navigateFileEnd: jest.fn()
})
