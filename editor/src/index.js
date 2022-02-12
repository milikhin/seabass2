import registerApi from './api/api'

import './css/app.css'

window.addEventListener('DOMContentLoaded', () => {
  // use timeout to allow platform-specific API backend to be initialized first
  setTimeout(() => registerApi({
    notifyOnLoaded: true,
    apiBackend: window.seabassOptions.apiBackend,

    rootElem: document.getElementById('root'),
    welcomeElem: document.getElementById('welcome')
  }))
})
