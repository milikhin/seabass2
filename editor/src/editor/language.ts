import { LanguageSupport, LanguageDescription } from '@codemirror/language'
import { languages } from '@codemirror/language-data'

/**
 * Guess language support extension by file name
 * @param filePath full path to file
 * @returns language support extension if found
 */
export async function getLanguageMode (filePath: string):
Promise<LanguageSupport|undefined> {
  const lang = LanguageDescription.matchFilename(languages, filePath)
  if (lang === null) {
    return
  }

  const langSupport = await lang.load()
  return langSupport
}
