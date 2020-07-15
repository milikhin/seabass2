export function setMainWindowColors (colors) {
  const styleElem = getThemeStyleElem()

  styleElem.sheet.cssRules[0].style.backgroundColor = colors.backgroundColor
  styleElem.sheet.cssRules[1].style.color = colors.textColor
  styleElem.sheet.cssRules[2].style.color = colors.highlightColor
}

export function setAutocompleteColors (colors) {
  const styleElem = getThemeStyleElem()

  styleElem.sheet.cssRules[3].style.backgroundColor = colors.foregroundColor
  styleElem.sheet.cssRules[3].style.color = colors.foregroundTextColor
}

export function setSearchBarColors (colors) {
  const styleElem = getThemeStyleElem()

  styleElem.sheet.cssRules[4].style.backgroundColor = colors.backgroundColor
  styleElem.sheet.cssRules[4].style.borderColor = colors.borderColor
  styleElem.sheet.cssRules[4].style.color = colors.textColor

  styleElem.sheet.cssRules[5].style.backgroundColor = colors.foregroundColor
  styleElem.sheet.cssRules[5].style.color = colors.foregroundTextColor
  styleElem.sheet.cssRules[6].style.backgroundColor = colors.foregroundColor
  styleElem.sheet.cssRules[6].style.setProperty('border-color', colors.borderColor, 'important')
  styleElem.sheet.cssRules[6].style.color = colors.textColor
}

export function getThemeStyleElem () {
  return document.getElementById('theme-css')
}
