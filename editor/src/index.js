import 'babel-polyfill'
import registerApi from './api'
import editorFactory from './editor-factory'

import './css/app.css'

setTimeout(() => {
  registerApi({
    editorFactory,
    notifyOnLoaded: true,
    apiBackend: window.seabassOptions.apiBackend,
    isSailfish: window.seabassOptions.isSailfish,
  
    rootElem: document.getElementById('root'),
    welcomeElem: document.getElementById('welcome')
  })
}, 2000)
