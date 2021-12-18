import registerApi from './api'

import './css/app.css'

window.addEventListener('DOMContentLoaded', () => {
  setTimeout(() => registerApi({
    notifyOnLoaded: true,
    apiBackend: window.seabassOptions.apiBackend,

    rootElem: document.getElementById('root'),
    welcomeElem: document.getElementById('welcome')
  }))
})
