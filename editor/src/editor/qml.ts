import {
  StreamLanguage,
  type IndentContext,
  type StreamParser,
  type StringStream
} from '@codemirror/language'
import { typescript } from '@codemirror/legacy-modes/mode/javascript'

/**
 * QML highlighting: a small parser for the declarative structure (imports,
 * objects, property/signal/enum declarations, binding names) that hands
 * binding values and functions over to the legacy JavaScript mode.
 */

/** The parts of the legacy JavaScript mode's state this mode looks at */
interface JsState {
  tokenize: unknown
  lastType: string
  indented: number
  cc: unknown[]
  fatArrowAt?: number | null
}

// QML functions may carry type annotations (`function f(a: int): string`) and
// cast with `as`, which only the TypeScript flavour of the mode understands.
const js = typescript as StreamParser<JsState>
const JS_BASE_TOKENIZE = js.startState!(0).tokenize

/** What the parser expects next outside of JavaScript */
type Step =
  | 'member' // an object member, or a top-level import/pragma/root object
  | 'value' // a binding value or a list element
  | 'objectType' // the type name of an object declaration
  | 'onTarget' // the property after `on` in `Behavior on x {`
  | 'import'
  | 'pragma'
  | 'propertyType'
  | 'propertyName'
  | 'signalName'
  | 'signalParams'
  | 'signalParamType'
  | 'enumName'
  | 'componentName'

/** Steps of a declaration that can't continue past the end of its line */
const LINE_STEPS = new Set<Step>([
  'objectType', 'onTarget', 'import', 'pragma', 'propertyType', 'propertyName',
  'signalName', 'signalParams', 'signalParamType', 'enumName', 'componentName'
])

interface Scope {
  kind: 'object' | 'list' | 'enum'
  /** indentation of the line that opened the scope */
  indented: number
}

interface QmlState {
  scopes: Scope[]
  step: Step
  /** indentation of the current line */
  indented: number
  inComment: boolean
  /** state of the JavaScript mode while inside a binding value or function */
  js: JsState | null
  /** brackets opened by that JavaScript and not closed yet */
  jsDepth: number
  /** the JavaScript is a function declaration that hasn't opened its body yet */
  jsAwaitsBody: boolean
}

/** Keywords that start a declaration, and where each one leads */
const KEYWORD_STEPS: Partial<Record<string, Step>> = {
  import: 'import',
  pragma: 'pragma',
  property: 'propertyType',
  signal: 'signalName',
  enum: 'enumName',
  component: 'componentName'
}

const MODIFIERS = new Set(['default', 'readonly', 'required', 'final', 'virtual', 'override'])

const IDENT = '[A-Za-z_$\\u00a1-\\uffff][\\w$\\u00a1-\\uffff]*'
const IDENT_RE = new RegExp(`^${IDENT}`)
/** A dotted member name and the rest of the line after it */
const PATH_RE = new RegExp(`^(${IDENT}(?:\\.${IDENT})*)(.*)$`)
/** An object declaration, `Type {` or `Namespace.Type {` */
const OBJECT_RE = new RegExp(`^(?:${IDENT}\\.)*[A-Z][\\w$]*\\s*\\{`)
/**
 * A bracket that opens a list of objects rather than a JavaScript array. A
 * bracket closing the line is taken as a list too: its elements go through
 * JavaScript one by one, so plain values still highlight correctly.
 */
const LIST_RE = new RegExp(`^\\[\\s*(?:$|\\/[/*]|(?:${IDENT}\\.)*[A-Z][\\w$]*\\s*\\{)`)

/**
 * JavaScript token types after which an expression goes on to the next line.
 * QML has no statement terminator for bindings, so without them a line break
 * ends the binding.
 */
const CONTINUING_TYPES = new Set([
  'sof', 'operator', ',', ':', '.', '=>', 'spread', 'keyword b', 'keyword c', 'new'
])

function peek (stream: StringStream, re: RegExp): RegExpMatchArray | null {
  return stream.match(re, false) as RegExpMatchArray | null
}

function isTypeName (name: string): boolean {
  return /^[A-Z]/.test(name)
}

function scopeStep (state: QmlState): Step {
  return state.scopes[state.scopes.length - 1]?.kind === 'list' ? 'value' : 'member'
}

function openScope (state: QmlState, kind: Scope['kind']): string {
  state.scopes.push({ kind, indented: state.indented })
  state.step = scopeStep(state)
  return 'punctuation'
}

/**
 * Closes the innermost scope of the given kind along with anything left open
 * inside it, so a missing bracket doesn't derail the rest of the file
 */
function closeScope (state: QmlState, kinds: Array<Scope['kind']>): string {
  let index = -1
  for (let i = state.scopes.length - 1; i >=0; i--) {
    const scope = state.scopes[i]
    if (kinds.includes(scope.kind)) {
      index = i
      break;
    }
  }
  if (index >= 0) {
    state.scopes.length = index
  }
  state.step = scopeStep(state)
  return 'punctuation'
}

function startJs (stream: StringStream, state: QmlState): void {
  const jsState = js.startState!(stream.indentUnit)
  // The JavaScript mode takes indentation from the line it starts on, which it
  // never sees the start of when the value follows `name:`
  jsState.indented = state.indented
  // It also looks for arrow function parameters only at the start of a line
  if (stream.match(/^(?:\([^()]*\)|[\w$]+)\s*=>/, false)) {
    jsState.fatArrowAt = stream.pos
  }
  state.js = jsState
  state.jsDepth = 0
  state.jsAwaitsBody = false
}

function endJs (state: QmlState): void {
  state.js = null
  state.jsDepth = 0
  state.jsAwaitsBody = false
  state.step = scopeStep(state)
}

/** Whether a line starting with `textAfter` still belongs to the current JavaScript */
function jsContinues (state: QmlState, textAfter: string): boolean {
  const jsState = state.js!
  if (state.jsDepth > 0 || state.jsAwaitsBody || jsState.tokenize !== JS_BASE_TOKENIZE) {
    return true
  }
  if (CONTINUING_TYPES.has(jsState.lastType)) {
    return true
  }
  // `if (x)` with the brace on the next line; a line can't start with a brace
  // after a complete binding
  if (textAfter.startsWith('{')) {
    return jsState.lastType === ')'
  }
  return /^(?!\/[/*])[-+*/%&|^!?:.<>=]/.test(textAfter)
}

/** Whether the JavaScript ends before the next token, which belongs to QML */
function jsEndsHere (stream: StringStream, state: QmlState): boolean {
  if (state.jsDepth > 0 || state.js!.tokenize !== JS_BASE_TOKENIZE) {
    return false
  }
  const separator = state.scopes[state.scopes.length - 1]?.kind === 'list' ? /^\s*[;,}\]]/ : /^\s*[;}\]]/
  return stream.match(separator, false) !== null
}

function tokenJs (stream: StringStream, state: QmlState): string | null {
  const jsState = state.js!
  const style = js.token(stream, jsState)
  if (style !== 'comment') {
    const text = stream.current()
    // `${` in a template string is closed by a plain `}` token
    if (/^[([{]$/.test(text) || (jsState.lastType === 'quasi' && text.endsWith('${'))) {
      state.jsDepth++
      if (text === '{') {
        state.jsAwaitsBody = false
      }
    } else if (/^[)\]}]$/.test(text)) {
      state.jsDepth = Math.max(0, state.jsDepth - 1)
    }
  }
  return style ?? null
}

function tokenComment (stream: StringStream, state: QmlState): string {
  if (stream.skipTo('*/')) {
    stream.pos += 2
    state.inComment = false
  } else {
    stream.skipToEnd()
  }
  return 'comment'
}

/** Strings, numbers and punctuation that need no context */
function tokenOther (stream: StringStream): string | null {
  const ch = stream.next()
  if (ch === '"' || ch === "'") {
    let escaped = false
    let next
    while ((next = stream.next()) !== undefined) {
      if (next === ch && !escaped) {
        break
      }
      escaped = !escaped && next === '\\'
    }
    return 'string'
  }
  if (ch !== undefined && /\d/.test(ch)) {
    stream.match(/^[\d.]*/)
    return 'number'
  }
  if (ch !== undefined && /[-=]/.test(ch)) {
    return 'operator'
  }
  if (ch !== undefined && /[{}[\]().,;:<>]/.test(ch)) {
    return 'punctuation'
  }
  return null
}

function tokenMember (stream: StringStream, state: QmlState): string | null {
  const path = peek(stream, PATH_RE)
  if (path === null) {
    if (stream.eat('{')) {
      // Brace on its own line after `Type`, or a group property like `font {`
      return openScope(state, 'object')
    }
    if (stream.eat('}')) {
      return closeScope(state, ['object'])
    }
    if (stream.eat(':')) {
      state.step = 'value'
      return 'punctuation'
    }
    return tokenOther(stream)
  }

  const [, name, rest] = path
  const segments = name.split('.')
  const word = segments[0]
  const isBinding = /^\s*:/.test(rest)

  if (!isBinding && segments.length === 1) {
    const keywordStep = KEYWORD_STEPS[word]
    if (keywordStep !== undefined) {
      stream.match(IDENT_RE)
      state.step = keywordStep
      return 'keyword'
    }
    if (MODIFIERS.has(word) && /^\s+[A-Za-z_$]/.test(rest)) {
      stream.match(IDENT_RE)
      return 'keyword'
    }
    if (word === 'function') {
      startJs(stream, state)
      // A return type may put the body on a line of its own after the header
      state.jsAwaitsBody = true
      return tokenJs(stream, state)
    }
  }

  if (!isBinding && isTypeName(segments[segments.length - 1]!)) {
    state.step = 'objectType'
    return tokenObjectType(stream, state)
  }

  stream.match(IDENT_RE)
  // Attached properties such as `Layout.fillWidth` are qualified by a type
  return isBinding && isTypeName(word) ? 'typeName' : 'propertyName'
}

function tokenValue (stream: StringStream, state: QmlState): string | null {
  if (state.scopes[state.scopes.length - 1]?.kind === 'list') {
    if (stream.eat(',')) {
      return 'punctuation'
    }
    if (stream.eat(']')) {
      return closeScope(state, ['list'])
    }
  }
  if (stream.eat('}')) {
    return closeScope(state, ['object'])
  }
  if (stream.eat(';')) {
    state.step = scopeStep(state)
    return 'punctuation'
  }
  if (stream.match(OBJECT_RE, false)) {
    state.step = 'objectType'
    return tokenObjectType(stream, state)
  }
  if (stream.match(LIST_RE, false)) {
    stream.next()
    return openScope(state, 'list')
  }
  startJs(stream, state)
  return tokenJs(stream, state)
}

function tokenObjectType (stream: StringStream, state: QmlState): string | null {
  if (stream.eat('{')) {
    return openScope(state, 'object')
  }
  const word = stream.match(IDENT_RE) as RegExpMatchArray | null
  if (word === null) {
    return tokenOther(stream)
  }
  if (word[0] === 'on') {
    state.step = 'onTarget'
    return 'keyword'
  }
  return stream.peek() === '.' ? 'namespace' : 'className'
}

function tokenOnTarget (stream: StringStream, state: QmlState): string | null {
  if (stream.eat('{')) {
    return openScope(state, 'object')
  }
  return stream.match(IDENT_RE) ? 'propertyName' : tokenOther(stream)
}

function tokenImport (stream: StringStream): string | null {
  const word = stream.match(IDENT_RE) as RegExpMatchArray | null
  if (word === null) {
    return tokenOther(stream)
  }
  return word[0] === 'as' ? 'keyword' : 'namespace'
}

/** A type in a declaration; `list<T>` and `Namespace.Type` take several tokens */
function tokenTypeRef (stream: StringStream, state: QmlState, next: Step): string | null {
  if (!stream.match(IDENT_RE)) {
    return tokenOther(stream)
  }
  const after = peek(stream, /^\s*([.<])/)?.[1]
  if (after === '.') {
    return 'namespace'
  }
  if (after !== '<') {
    state.step = next
  }
  return 'typeName'
}

function tokenSignalParams (stream: StringStream, state: QmlState): string | null {
  if (stream.eat(':')) {
    state.step = 'signalParamType'
    return 'punctuation'
  }
  if (stream.eat(')')) {
    state.step = 'member'
    return 'punctuation'
  }
  if (!stream.match(IDENT_RE)) {
    return tokenOther(stream)
  }
  // Old-style parameters put the type first: `signal moved(int x, list<int> y)`
  return peek(stream, /^\s*[\w$.<>]/) ? 'typeName' : 'variableName.definition'
}

function tokenSignalParamType (stream: StringStream, state: QmlState): string | null {
  if (stream.eat(',')) {
    state.step = 'signalParams'
    return 'punctuation'
  }
  if (stream.eat(')')) {
    state.step = 'member'
    return 'punctuation'
  }
  return tokenTypeRef(stream, state, 'signalParamType')
}

function tokenEnumBody (stream: StringStream, state: QmlState): string | null {
  if (stream.eat('}')) {
    return closeScope(state, ['enum'])
  }
  return stream.match(IDENT_RE) ? 'variableName.constant' : tokenOther(stream)
}

function tokenDeclaredName (stream: StringStream, state: QmlState, style: string, next: Step): string | null {
  if (!stream.match(IDENT_RE)) {
    return tokenOther(stream)
  }
  state.step = next
  return style
}

function tokenQml (stream: StringStream, state: QmlState): string | null {
  if (state.inComment) {
    return tokenComment(stream, state)
  }
  if (stream.eatSpace()) {
    return null
  }
  if (stream.match('//')) {
    stream.skipToEnd()
    return 'comment'
  }
  if (stream.match('/*')) {
    state.inComment = true
    return tokenComment(stream, state)
  }
  if (state.scopes[state.scopes.length - 1]?.kind === 'enum') {
    return tokenEnumBody(stream, state)
  }

  switch (state.step) {
    case 'member':
      return tokenMember(stream, state)
    case 'value':
      return tokenValue(stream, state)
    case 'objectType':
      return tokenObjectType(stream, state)
    case 'onTarget':
      return tokenOnTarget(stream, state)
    case 'import':
      return tokenImport(stream)
    case 'pragma':
      return stream.match(IDENT_RE) ? 'atom' : tokenOther(stream)
    case 'propertyType':
      return tokenTypeRef(stream, state, 'propertyName')
    case 'propertyName':
      return tokenDeclaredName(stream, state, 'propertyName.definition', 'member')
    case 'signalName':
      return tokenDeclaredName(stream, state, 'variableName.function.definition', 'signalParams')
    case 'signalParams':
      return tokenSignalParams(stream, state)
    case 'signalParamType':
      return tokenSignalParamType(stream, state)
    case 'enumName':
      if (stream.eat('{')) {
        return openScope(state, 'enum')
      }
      return tokenDeclaredName(stream, state, 'typeName.definition', 'enumName')
    case 'componentName':
      // `component Name: Type {`: the colon leads to an object declaration
      if (stream.eat(':')) {
        state.step = 'value'
        return 'punctuation'
      }
      return tokenDeclaredName(stream, state, 'typeName.definition', 'componentName')
  }
}

const qmlParser: StreamParser<QmlState> = {
  name: 'qml',

  startState: () => ({
    scopes: [],
    step: 'member',
    indented: 0,
    inComment: false,
    js: null,
    jsDepth: 0,
    jsAwaitsBody: false
  }),

  copyState: state => ({
    ...state,
    scopes: state.scopes.slice(),
    js: state.js && { ...state.js, cc: state.js.cc.slice() }
  }),

  token (stream, state) {
    if (stream.sol()) {
      state.indented = stream.indentation()
      if (state.js !== null && !jsContinues(state, stream.string.trimStart())) {
        endJs(state)
      }
      if (LINE_STEPS.has(state.step)) {
        state.step = scopeStep(state)
      }
    }
    if (state.js !== null && jsEndsHere(stream, state)) {
      endJs(state)
    }
    return state.js !== null ? tokenJs(stream, state) : tokenQml(stream, state)
  },

  indent (state: QmlState, textAfter: string, cx: IndentContext) {
    if (state.inComment) {
      return null
    }
    if (state.js !== null && jsContinues(state, textAfter)) {
      return js.indent!(state.js, textAfter, cx)
    }
    const scope = state.scopes.at(-1)
    if (scope === undefined) {
      return 0
    }
    return /^[}\]]/.test(textAfter) ? scope.indented : scope.indented + cx.unit
  },

  languageData: {
    commentTokens: { line: '//', block: { open: '/*', close: '*/' } },
    closeBrackets: { brackets: ['(', '[', '{', "'", '"', '`'] },
    indentOnInput: /^\s*(?:case .*?:|default:|\{|\}|\])$/,
    wordChars: '$'
  }
}

export const qml = StreamLanguage.define(qmlParser)
