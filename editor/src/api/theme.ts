interface ThemeColors {
  backgroundColor: string
  textColor: string
  highlightColor: string
}

export function setWelcomeScreenColors (colors: ThemeColors): void {
  const styleElem = document.getElementById('theme-css') as HTMLStyleElement
  if (styleElem.sheet === null) {
    return
  }

  const rules = styleElem.sheet.cssRules
  ;(rules.item(0) as CSSStyleRule).style.backgroundColor = colors.backgroundColor
  ;(rules.item(1) as CSSStyleRule).style.color = colors.textColor
  ;(rules.item(2) as CSSStyleRule).style.color = colors.highlightColor
}
