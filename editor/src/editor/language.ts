import { LanguageSupport, LanguageDescription } from '@codemirror/language'
import { languages } from '@codemirror/language-data'

export async function getLanguageMode (filePath: string):
Promise<LanguageSupport|undefined> {
  const lang = LanguageDescription.matchFilename(languages, filePath)
  if (lang === null) {
    return
  }

  const langSupport = await lang.load()
  return langSupport
}
