import SeabassAppModel, { SeabassHtmlTheme, ViewportOptions } from './model'

interface SeabassViewOptions {
  model: SeabassAppModel
  rootElem: HTMLElement
  welcomeElem: HTMLElement
}

export default class SeabassView {
  _model: SeabassAppModel
  /** Wecome notes root elem */
  _welcomeElem: HTMLElement
  /** Tabs container elem */
  _rootElem: HTMLElement
  /** Platform-specific API backend name */

  constructor ({ model, rootElem, welcomeElem }: SeabassViewOptions) {
    this._model = model
    this._rootElem = rootElem
    this._welcomeElem = welcomeElem
    this._registerEventListeners()
  }

  /**
   * Shows welcome note, hides tabs interface
   */
  showWelcomeScreen (): void {
    this._welcomeElem.style.display = 'block'
    this._rootElem.style.display = 'none'
  }

  /**
   * Shows tabs interface, hides welcome note
   */
  showTabs (): void {
    this._welcomeElem.style.display = 'none'
    this._rootElem.style.display = 'block'
  }

  _onHtmlThemeChange (options: SeabassHtmlTheme): void {
    const styleElem = document.getElementById('theme-css') as HTMLStyleElement
    if (styleElem.sheet === null) {
      return
    }

    const rules = styleElem.sheet.cssRules
    ;(rules.item(0) as CSSStyleRule).style.backgroundColor = options.backgroundColor
    ;(rules.item(1) as CSSStyleRule).style.color = options.textColor
    ;(rules.item(2) as CSSStyleRule).style.color = options.highlightColor
    if (options.fontSize !== undefined) {
      (rules.item(3) as CSSStyleRule).style.fontSize = `${options.fontSize}px`
    }
  }

  _onViewportChange (options: ViewportOptions): void {
    document.documentElement.style.bottom = `${options.verticalHtmlOffset}px`
  }

  _registerEventListeners (): void {
    this._model.addEventListener('htmlThemeChange', evt => {
      this._onHtmlThemeChange(evt.detail)
    })
    this._model.addEventListener('viewportChange', evt => {
      this._onViewportChange(evt.detail)
    })
    this._model.addEventListener('loadFile', () => {
      this.showTabs()
    })
    this._model.addEventListener('closeFile', () => {
      if (this._model._editors.size === 0) {
        this.showWelcomeScreen()
      }
    })
  }
}
