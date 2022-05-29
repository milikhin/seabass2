import { FileActionOptions } from '../api/api-interface'
import Editor, { SeabassEditorState } from '../editor/editor'
import { LoadFileOptions } from './types'

export interface EditorStateChangeOptions extends SeabassEditorState {
  filePath: string
}

export interface SeabassHtmlTheme {
  backgroundColor: string
  highlightColor: string
  textColor: string
}

export interface SeabassCommonPreferences {
  isDarkTheme: boolean
  verticalHtmlOffset: number
}

export interface SeabassSailfishPreferences {
  isToolbarOpened: boolean
}

export type InputPreferences = SeabassHtmlTheme & Partial<SeabassCommonPreferences>

interface Events {
  htmlThemeChange: CustomEvent<SeabassHtmlTheme>
  closeFile: CustomEvent<FileActionOptions>
  loadFile: CustomEvent<LoadFileOptions>
  log: CustomEvent<unknown>
  preferencesChange: CustomEvent<SeabassCommonPreferences>
  sfosPreferencesChange: CustomEvent<SeabassSailfishPreferences>
  stateChange: CustomEvent<EditorStateChangeOptions>
}

type AppEventListener <T extends keyof Events> = ((evt: Events[T]) => void) | ({ handleEvent: (evt: Events[T]) => void }) | null

export default class SeabassAppModel extends EventTarget {
  _editors: Map<string, Editor>

  /** Welcome note theme */
  _htmlTheme?: {
    backgroundColor: string
    textColor: string
    highlightColor: string
  }

  /** App preferences */
  _preferences: {
    isDarkTheme: boolean
    verticalHtmlOffset: number
  }

  /** SailfishOS-specific preferences */
  _sailfish: {
    isToolbarOpened: boolean
  }

  SFOS_TOOLBAR_LOCAL_STORAGE_KEY = 'sailfish__isToolbarOpened'

  constructor () {
    super()
    this._editors = new Map()
    this._preferences = {
      isDarkTheme: false,
      verticalHtmlOffset: 0
    }
    this._sailfish = {
      isToolbarOpened: localStorage.getItem(this.SFOS_TOOLBAR_LOCAL_STORAGE_KEY) === 'true'
    }
  }

  get sailfishPreferences (): SeabassSailfishPreferences {
    return this._sailfish
  }

  addEventListener<T extends keyof Events> (type: T,
    callback: AppEventListener<T>, options?: EventListenerOptions): void {
    super.addEventListener(type, callback as EventListenerOrEventListenerObject | null, options)
  }

  dispatchEvent<T extends keyof Events> (event: Events[T]): boolean {
    return super.dispatchEvent(event)
  }

  closeFile (filePath: string): void {
    const editor = this._editors.get(filePath)
    if (editor !== undefined) {
      editor.destroy()
      this._editors.delete(filePath)
    }

    this.dispatchEvent(new CustomEvent('closeFile', { detail: { filePath } }))
  }

  getContent (filePath: string): string {
    const editor = this._editors.get(filePath)
    if (editor === undefined) {
      throw new Error(`File ${filePath} is not opened`)
    }

    return editor.getContent()
  }

  forwardEvent (filePath: string, evt: CustomEvent): void {
    const editor = this._editors.get(filePath)
    const action = evt.type as keyof Editor
    if (editor === undefined || typeof editor[action] !== 'function') {
      return
    }

    const handler = editor[action] as (options: unknown) => void
    handler.call(editor, evt.detail)
  }

  loadFile (options: LoadFileOptions, editorElem: HTMLElement): void {
    const filePath = options.filePath
    const editor = new Editor({
      content: options.content,
      editorConfig: options.editorConfig,
      elem: editorElem,
      filePath,
      isReadOnly: options.isReadOnly,
      isDarkTheme: this._preferences.isDarkTheme
    })
    editor.addEventListener('stateChange', evt => {
      this.dispatchEvent(new CustomEvent('stateChange', {
        detail: { ...evt.detail, filePath }
      }))
    })
    this._editors.set(filePath, editor)
    this.dispatchEvent(new CustomEvent('loadFile', { detail: options }))
  }

  setPreferences (options: InputPreferences): void {
    this._htmlTheme = {
      backgroundColor: options.backgroundColor,
      textColor: options.textColor,
      highlightColor: options.highlightColor
    }

    this._preferences = {
      isDarkTheme: options.isDarkTheme ?? false,
      verticalHtmlOffset: options.verticalHtmlOffset ?? 0
    }

    this.dispatchEvent(new CustomEvent('htmlThemeChange', { detail: this._htmlTheme }))
    this.dispatchEvent(new CustomEvent('preferencesChange', { detail: this._preferences }))
  }

  setSailfishPreferences (options: SeabassSailfishPreferences): void {
    this._sailfish = {
      isToolbarOpened: options.isToolbarOpened
    }
    localStorage.setItem(this.SFOS_TOOLBAR_LOCAL_STORAGE_KEY, options.isToolbarOpened.toString())
    this.dispatchEvent(new CustomEvent('sfosPreferencesChange', { detail: this._sailfish }))
  }
}
