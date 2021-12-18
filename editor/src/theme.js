export function setMainWindowColors (colors) {
  const styleElem = getThemeStyleElem()

  styleElem.sheet.cssRules[0].style.backgroundColor = colors.backgroundColor
  styleElem.sheet.cssRules[1].style.color = colors.textColor
  styleElem.sheet.cssRules[2].style.color = colors.highlightColor
}

export function getThemeStyleElem () {
  return document.getElementById('theme-css')
}
