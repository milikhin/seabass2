import { StreamLanguage, StringStream } from '@codemirror/language'
import { tags as t } from '@lezer/highlight'

const keywords = new Set([
  'import', 'property', 'readonly', 'signal', 'alias', 'on', 'as',
  'function', 'var', 'let', 'const', 'if', 'else', 'for', 'while', 'do',
  'break', 'continue', 'return', 'switch', 'case', 'default',
  'try', 'catch', 'finally', 'with', 'new', 'delete', 'typeof', 'instanceof', 'void'
])

const builtins = new Set([
  'int', 'real', 'double', 'bool', 'string', 'date',
  'matrix4x4', 'point', 'rect', 'size', 'variant', 'vector2d', 'vector3d', 'vector4d', 'list'
])

// Primitives that shouldn't be tagged as types or variables
const atoms = new Set(['true', 'false', 'null', 'undefined', 'NaN', 'Infinity'])

// We add 'ternaryDepth' to the state to differentiate property colons from ternary colons
interface QMLState {
  tokenize: (stream: StringStream, state: QMLState) => string | null
  ternaryDepth: number
}

function tokenBase(stream: StringStream, state: QMLState): string | null {
  const ch = stream.next()

  if (ch === '"' || ch === "'") {
    state.tokenize = tokenString(ch)
    return state.tokenize(stream, state)
  }

  if (ch === '/') {
    if (stream.eat('/')) {
      stream.skipToEnd()
      return 'comment'
    }
    if (stream.eat('*')) {
      state.tokenize = tokenComment
      return tokenComment(stream, state)
    }
  }

  if (/\d/.test(ch)) {
    stream.eatWhile(/[\w\.]/)
    return 'number'
  }

  // --- NEW: Handle Ternary Operators vs Property Assignments ---
  if (ch === '?') {
    state.ternaryDepth++
    return 'operator'
  }

  if (ch === ':') {
    if (state.ternaryDepth > 0) {
      state.ternaryDepth--
      return 'operator' // This colon belongs to a ternary operator
    }
    return 'punctuation' // This colon assigns a property
  }

  if (/[-+\/*=<>!|&~^%]/.test(ch)) {
    stream.eatWhile(/[-+\/*=<>!|&~^%]/)
    return 'operator'
  }

  if (/[a-zA-Z_\.]/.test(ch)) {
    stream.eatWhile(/[a-zA-Z0-9_]/)
    const word = stream.current()

    if (keywords.has(word)) return 'keyword'
    if (builtins.has(word)) return 'typeName'
    if (atoms.has(word)) return 'atom' // true/false/null will now color differently

    if (/^[\.A-Z]/.test(word) && stream.match(/^[a-zA-Z0-9_.]*\s*{/, false)) return 'className'

    // Only tag as property name if a colon follows AND we aren't in a ternary operator
    if (state.ternaryDepth === 0 && stream.match(/^[a-zA-Z0-9_.]*\s*:/, false)) {
      return 'propertyName'
    }

    return 'content'
  }

  if (/[{}[\](),;]/.test(ch)) {
    // Safety reset to prevent syntax errors from bleeding into next lines
    if (ch === ';' || ch === '{' || ch === '}') {
      state.ternaryDepth = 0
    }
    return 'punctuation'
  }

  return null
}

function tokenString(quote: string) {
  return function (stream: StringStream, state: QMLState): string {
    let escaped = false
    let ch
    while ((ch = stream.next()) != null) {
      if (ch === quote && !escaped) {
        state.tokenize = tokenBase
        break
      }
      escaped = !escaped && ch === '\\'
    }
    return 'string'
  }
}

function tokenComment(stream: StringStream, state: QMLState): string {
  let maybeEnd = false
  let ch
  while ((ch = stream.next()) != null) {
    if (ch === '/' && maybeEnd) {
      state.tokenize = tokenBase
      break
    }
    maybeEnd = (ch === '*')
  }
  return 'comment'
}

export const qmlStreamLanguage = StreamLanguage.define<QMLState>({
  name: 'qml',
  startState: () => ({
    tokenize: tokenBase,
    ternaryDepth: 0
  }),
  token: (stream, state) => {
    if (stream.eatSpace()) return null
    return state.tokenize(stream, state)
  },
  tokenTable: {
    keyword: t.keyword,
    typeName: t.typeName,
    className: t.className,
    propertyName: t.propertyName,
    atom: t.atom,
    content: t.content,
    string: t.string,
    number: t.number,
    comment: t.comment,
    operator: t.operator,
    punctuation: t.punctuation
  }
})
