import registerApi from './api'
import editorFactory from './editor-factory'

registerApi({
  editorFactory,
  notifyOnLoaded: true,
  apiBackend: 'url',

  rootElem: document.getElementById('root'),
  welcomeElem: document.getElementById('welcome')
})
