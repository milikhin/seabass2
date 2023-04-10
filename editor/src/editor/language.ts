import { LanguageDescription } from '@codemirror/language'
import { languages } from '@codemirror/language-data'
import { languageServer } from './codemirror-ls'
import { Extension } from '@codemirror/state'

const PORT = 8399

const LSP_LANGUAGES = new Map([
  ['C++', 'cpp'],
  ['JavaScript', 'javascript'],
  ['Python', 'python'],
  ['TypeScript', 'typescript']
])

function getLSPName (langName: string): string|undefined {
  return LSP_LANGUAGES.get(langName)
}

/**
 * Guess language support extension by file name
 * @param filePath full path to file
 * @param isLsEnabled language server's availability
 * @returns language support extension if found
 */
export async function getLanguageMode (filePath: string, isLsEnabled: boolean):
Promise<Extension[]|undefined> {
  const lang = LanguageDescription.matchFilename(languages, filePath)
  if (lang === null) {
    return
  }

  const langSupport: Extension[] = [await lang.load()]
  const lspName = getLSPName(lang.name)
  if (isLsEnabled && lspName !== undefined) {
    const serverUri = `ws://localhost:${PORT}/${lspName}` as `ws://${string}`
    const ls = languageServer({
      // WebSocket server uri and other client options.
      serverUri,
      rootUri: 'file:///',
      workspaceFolders: [],

      documentUri: `file://${filePath}`,
      // As defined at https://microsoft.github.io/language-server-protocol/specification#textDocumentItem
      languageId: lspName
    })
    langSupport.push(...ls)
  }

  return langSupport
}
