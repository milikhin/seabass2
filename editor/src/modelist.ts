const MODES: Record<string, Array<string|[string, Record<string, boolean>]>> = {
  cpp: ['cpp', 'c', 'cc', 'cxx', 'h', 'hh', 'hpp', 'ino'],
  css: ['css'],
  html: ['html', 'htm', 'xhtml', 'vue', 'we', 'wpy'],
  java: ['java'],
  javascript: [
    'js',
    'jsm',
    ['jsx', { jsx: true }]
  ],
  json: ['json', 'json5'],
  JSX: ['jsx'],
  Markdown: ['md', 'markdown'],
  PHP: ['php', 'inc', 'phtml', 'shtml', 'php3', 'php4', 'php5', 'phps', 'phpt', 'aw', 'ctp', 'module'],
  Python: ['py'],
  Rust: ['rs'],
  XML: ['xml', 'rdf', 'rss', 'wsdl', 'xslt', 'atom', 'mathml', 'mml', 'xul', 'xbl', 'xaml']
}

export default function getMode (fileName: string) {
  const extMatcher = fileName.match(/\.(\w+)$/)
  if (!extMatcher) {
    return
  }
  const ext = extMatcher[1]

  const mode = Object
    .entries(MODES)
    .find(([key, languages]) => {
      return languages.find(language => {
        if (Array.isArray(language)) {
          return language[0] === ext
        }

        return language === ext
      })
    })
  return mode
}
